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

class SpeechVideoProcessing < VideoProcessing

  def self.process_speech(shell,logger,worker_config)
    @@logger = logger
    @@shell = shell
    @@worker_config = worker_config
    found = false
    ProcessSpeechMasterVideo.find(:all, :conditions=>"published = 1 AND in_processing = 0 AND url != ''", :order=>"url", :lock=>true).each do |master_video|
      master_video.in_processing = true
      master_video.save
      unless master_video.process_speech_videos.all_done? and not master_video.process_speech_videos.any_in_processing?
        found = true
        convert_all_speeches_to_flash(master_video)
        master_video.reload :lock=>true
        master_video.in_processing = false
        master_video.save
        break
      end
      master_video.reload :lock=>true
      master_video.in_processing = false
      master_video.save
    end
    check_load_and_wait
    if found
      return true
    else
      return false
    end
  end

  def self.convert_all_speeches_to_flash(master_video)
    master_video_filename = "#{Rails.root.to_s}/private/"+ENV['Rails.env']+"/process_speech_master_videos/#{master_video.id}/master.flv"
    cut_points = []
    master_video.process_speech_videos.each do |video|
      speech_video_path = "#{Rails.root.to_s}/public/"+ENV['Rails.env']+"/process_speech_videos/#{video.id}/"
      speech_video_first_tmp_filename = speech_video_path+"speech.tmp_1.flv"
      FileUtils.mkpath(speech_video_path)
      inpoint_ms = video.inpoint_s*1000

      inpoint_ms += 200 # mencoder video delay
      inpoint_ms -= 2000 # shift forward (after experimenting)                   
                  
      if video.modified_duration_s
        duration_ms = video.modified_duration_s*1000
        duration_s = video.modified_duration_s
      else
        duration_ms = video.duration_s*1000
        duration_s = video.duration_s
      end
      outpoint_ms = inpoint_ms + duration_ms
      cut_points << [inpoint_ms,outpoint_ms,speech_video_first_tmp_filename]
      inpoint_s = [inpoint_ms/1000,0].max
      @@shell.execute("ffmpeg -ss #{[inpoint_s/3600, inpoint_s/60 % 60, inpoint_s % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')} \
                       -t #{[duration_s/3600, duration_s/60 % 60, duration_s % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')} \
                       -i #{master_video_filename} -acodec copy -vcodec copy -y #{speech_video_first_tmp_filename}")
    end

    master_video.process_speech_videos.each do |video|
      video.in_processing = true
      video.save
      @@logger.info("VIDEO TO PROCESS: #{video.title}")
      @@logger.info("PROCESS: #{video.process_discussion.meeting_url}")
      speech_video_path = "#{Rails.root.to_s}/public/"+ENV['Rails.env']+"/process_speech_videos/#{video.id}/"
      flvedit_path = "#{Rails.root.to_s}/workers/video/flvedit"
      flvedit_lib = "#{Rails.root.to_s}/workers/video/lib"
      speech_video_first_tmp_filename = speech_video_path+"speech.tmp_1.flv"
      speech_video_second_tmp_filename = speech_video_path+"speech.tmp_2.flv"
      speech_video_third_tmp_filename = speech_video_path+"speech.tmp_3.flv"
      speech_video_filename = speech_video_path+"speech.flv"
      @@shell.execute("mencoder -of lavf -ovc lavc -lavcopts vcodec=flv:vbitrate=400:keyint=230:vqmin=3 -oac copy -ofps 25 -vf \"harddup\"\
       #{speech_video_first_tmp_filename} -o #{speech_video_second_tmp_filename}")
      @@shell.execute("ruby -I#{flvedit_lib} #{flvedit_path} #{speech_video_second_tmp_filename} -u --save #{speech_video_third_tmp_filename}")
      @@shell.execute("rm #{speech_video_first_tmp_filename} #{speech_video_second_tmp_filename}")
      @@shell.execute("mv #{speech_video_third_tmp_filename} #{speech_video_filename}")
      video.reload :lock=>true
      video.published = 1
      video.in_processing = 0
      video.save
    end
  end

  def self.print_all_sub_videos(video)
    if video.children.size > 0
      video.children.each do |subvideo| 
        print_video(subvideo)
        if subvideo.children.size > 0
          print_all_sub_videos(subvideo)
        end
      end
    end
  end

  def self.print_video(video)
    @@logger.info("level: #{video.ancestors.length} id:#{video.id} title:#{video.title}")
  end

  def self.print_tree
    csv = ProcessSpeechVideo.find(:all, :conditions=>"parent_id IS NULL")
    for video in csv
      print_video(video)
      print_all_sub_videos(video)
    end
  end
  
  def self.print_timecode
    ProcessSpeechVideo.find(:all, :conditions=>"published = 1", :order=>"start_offset").each do |video|
      if video.modified_duration_s
        @@logger.info("#{video.process_discussion.id} #{video.inpoint_s}-#{video.modified_outpoint_s} (#{video.modified_duration_s}s) - #{video.title}")
      else
        @@logger.info("#{video.process_discussion.id} #{video.inpoint_s}-#{video.outpoint_s} (#{video.duration_s}s) - #{video.title}")
      end
    end
  end  
end