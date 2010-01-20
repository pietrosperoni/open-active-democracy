module ProcessSpeechVideosHelper
  def video_share_title(video)
    "#{video.title} #{t(:about_process)} #{video.process_discussion.process.external_info_1} - #{video.process_discussion.stage_sequence_number}. #{t(:stage_sequence_discussion)}"
  end

  def video_share_description(video)
    "#{video.title} #{t(:about_process)} #{video.process_discussion.process.external_info_1} (#{video.process_discussion.process.external_info_2}) / #{video.process_discussion.process.external_info_3} - #{video.process_discussion.stage_sequence_number}. #{t(:stage_sequence_discussion)}"
  end
end
