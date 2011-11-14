# Copyright (C) 2008,2009,2010 Róbert Viðar Bjarnason
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
require 'rubygems'
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'iconv'
require 'sys/filesystem'
require 'yaml'
require 'utils/logger.rb'
require 'utils/shell.rb'

require File.dirname(__FILE__) + '/../../config/boot'
require File.dirname(__FILE__) + "/../../config/environment"

include Sys

MASTER_TEST_MAX_COUNTER = 500000
MIN_FREE_SPACE_GB = 30
SLEEP_WAITING_FOR_FREE_SPACE_TIME = 120
SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN = 120
SLEEP_WAITING_BETWEEN_RUNS = 5
EMAIL_REPORTING_INTERVALS = 86000
LINK_PREFIX = "http://www.althingi.is/altext/"

require 'discussion_processing'
require 'master_processing'
require 'speech_video_processing'

f = File.open( File.dirname(__FILE__) + '/config/worker.yml')
worker_config = YAML.load(f)
Rails.env = worker_config['rails_env']
config = YAML::load(File.open(File.dirname(__FILE__) + "/../../config/database.yml"))

class VideoWorker
  def initialize(config)
    @logger = Logger.new(File.dirname(__FILE__) + "/../../log/video_"+Rails.env+".log")
    @shell = Shell.new(self)
    @worker_config = config
    @counter = 0
    @last_report_time = 0
  end

  def create_thumbnails(video)
    speech_video_path = "#{Rails.root.to_s}/public/"+ENV['Rails.env']+"/process_speech_videos/#{video.id}/"
    speech_video_filename = speech_video_path+"speech.flv"
    begin
      timepoints = []
      slice_time_sec = video.duration_s/5
      slice_id = 1
      timepoints << [7,video.duration_s-1].min
      3.times do
        timepoints << slice_id*slice_time_sec
        slice_id+=1
      end
      timepoints << [video.duration_s-7,1].max
      pngid=0
      #@@logger.info("Timepoints: #{timepoints.inspect} video duration: #{video.duration_s}")
      timepoints.sort.each do |time|
        filename = "thumb_#{pngid+=1}.png"
        if video.title =~ /forseti/i
          pos_x = 190
          pos_y = 45
        else
          pos_x = 232
          pos_y = 125
        end
        @shell.execute("ffmpeg -ss #{[time/3600, time/60 % 60, time % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')} -i #{speech_video_filename} \
          -an -r 1 -vframes 1 -vf crop=252:156:#{pos_x}:#{pos_y} -y #{speech_video_path}#{filename}")
        @shell.execute("convert #{speech_video_path}#{filename} -resize 160x99 #{speech_video_path}small_#{filename}")
        @shell.execute("convert #{speech_video_path}#{filename} -resize 80x50 #{speech_video_path}smaller_#{filename}")
        @shell.execute("convert #{speech_video_path}#{filename} -resize 45x28 #{speech_video_path}tiny_#{filename}")
      end
    rescue
      video.reload
      video.in_processing = true
      video.published = false
      video.save
      error("ERROR CREATING THUMBNAILS for video id #{video.id}")
    end
  end

  def log_time
    t = Time.now
    "%02d/%02d %02d:%02d:%02d.%06d" % [t.day, t.month, t.hour, t.min, t.sec, t.usec]
  end

  def info(text)
    @logger.info("cs_info %s: %s" % [log_time, text])
  end

  def warn(text)
    @logger.warn("cs_warn %s: %s" % [log_time, text])
  end

  def error(text)
    @logger.error("cs_error %s: %s" % [log_time, text])
  end

  def debug(text)
    @logger.debug("cs_debug %s: %s" % [log_time, text])
  end

  def ensure_mysql_connection
    unless ActiveRecord::Base.connection.active?
      unless ActiveRecord::Base.connection.reconnect!
        error("Couldn't reestablish connection to MYSQL")
      end
    end
  end

  def load_avg
    results = ""
    IO.popen("cat /proc/loadavg") do |pipe|
      pipe.each("\r") do |line|
        results = line
        pipe.flush
      end
    end
    results.split[0..2].map{|e| e.to_f}
  end

  def run
    info("Starting loop")
    loop do
      stat = Filesystem.stat(@worker_config["master_path_for_filesystem_stats"]+"/")
      freeGB = (stat.block_size * stat.blocks_available) /1024 / 1024 / 1024
      if @last_report_time+EMAIL_REPORTING_INTERVALS<Time.now.to_i
        #email_progress_report(freeGB) unless Rails.env=="development"
        @last_report_time = Time.now.to_i
      end
      info("Free video space in GB #{freeGB} - Run count: #{@counter}")
      info("Load Average #{load_avg[0]}, #{load_avg[1]}, #{load_avg[2]}")      
      if load_avg[0] < @worker_config["max_load_average"]
        if freeGB > MIN_FREE_SPACE_GB
          if Rails.env == 'development' && @counter > MASTER_TEST_MAX_COUNTER
            warn("Reached maximum number of tests - sleeping for an hour")
            sleep(3600)
          else
            @counter = @counter + 1
            begin
              poll_for_work
            rescue => ex
              error("Problem with video worker")
              error(ex)
              error(ex.backtrace)
              ensure_mysql_connection
            end
          end
          info("Sleeping for #{SLEEP_WAITING_BETWEEN_RUNS} sec")
          sleep(SLEEP_WAITING_BETWEEN_RUNS)
        else
          info("No more space on disk for cache - sleeping for #{SLEEP_WAITING_FOR_FREE_SPACE_TIME} sec")
          sleep(SLEEP_WAITING_FOR_FREE_SPACE_TIME)
        end
      else
        info("Load average too high at: #{load_avg[0]} - sleeping for #{SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN} sec")
        sleep(SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN)
      end
    end
    info "THE END"
  end

  def poll_for_work
    ProcessSpeechMasterVideo.find(:all, conditions: "published = 1 AND in_processing = 0 AND url != '' AND renew_screenshots = 1").each do |master_video|
      master_video.process_speech_videos.each do |speech_video|
        create_thumbnails(speech_video)
      end
      master_video.renew_screenshots = false
      master_video.save
    end
    unless @worker_config["only_get_masters"] and @worker_config["only_get_masters"]==true
      info "process_discussion"
      run_counter = 0
      while DiscussionProcessing.process_discussion_items(@logger)
        info "poll_for_work process_discussion run counter: #{run_counter+=1}"
      end
      info "process_modify_durations"
      run_counter = 0
      while DiscussionProcessing.process_modify_durations(@logger)
        info "poll_for_work process_modify_durations run counter: #{run_counter+=1}"
      end
    end
    unless @worker_config["skip_masters"] and @worker_config["skip_masters"]==true
      info "process_master"
      MasterProcessing.process_master(@shell,@logger,@worker_config)
    end
    unless @worker_config["only_get_masters"] and @worker_config["only_get_masters"]==true
      info "process_speech"
      run_counter = 0
      while SpeechVideoProcessing.process_speech(@shell,@logger,@worker_config)
        info "poll_for_work process_speech run counter: #{run_counter+=1}"
      end
    end
  end
end

video_worker = VideoWorker.new(worker_config)
video_worker.run
