class FixMasterVideoUrl < ActiveRecord::Migration
  def self.up
    ProcessSpeechMasterVideo.transaction do
      ProcessSpeechMasterVideo.all.each do |pro|
        pro.url = pro.url.sub(/^\w+:/, 'mms:')
        pro.save
      end
    end
  end

  def self.down
  end
end
