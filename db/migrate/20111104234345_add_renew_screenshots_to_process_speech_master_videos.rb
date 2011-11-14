class AddRenewScreenshotsToProcessSpeechMasterVideos < ActiveRecord::Migration
  def self.up
    add_column :process_speech_master_videos, :renew_screenshots, :boolean, :default => true
  end

  def self.down
  end
end
