require 'rubygems'
require 'daemons'
require 'yaml'

f = File.open( File.dirname(__FILE__) + '/config/worker.yml')
worker_config = YAML.load(f)

ENV['Rails.env'] = worker_config['rails_env']

options = {
    :app_name   => "video_worker_"+ENV['Rails.env'],
    :dir_mode   => :normal,
    :backtrace  => true,
    :monitor    => true,
    :log_output => true,
    :multiple => true,
    :dir =>File.open( File.dirname(__FILE__) + "/../../pids"),
    :script     => "video_worker_daemon.rb" 
  }

Daemons.run(File.join(File.dirname(__FILE__), 'video_worker_daemon.rb'), options)
