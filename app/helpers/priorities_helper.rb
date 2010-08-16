module PrioritiesHelper

  def has_process_documents?
    #TODO: Create optimized ActiveRecrods/SQL for this
    found = false
    @priority.priority_processes.each do |process|
      process.process_documents.each do |document|
        found = true
      end
    end
    found
  end

  def has_process_discussions?
    #TODO: Create optimized ActiveRecrods/SQL for this
    found = false
    @priority.priority_processes.each do |process|
      process.process_discussions.each do |discussion|
        found = true if discussion.process_speech_videos.get_first_published
      end
    end
    found
  end
  
  def get_questions_number_text(questions_count, total_points,new_points=false)
    if questions_count>0
      "<span style=\"color:#666;font-size:0.75em;\">(#{questions_count} af #{total_points})</span>"
    else
      "<span style=\"color:#666;font-size:0.75em;\">(#{new_points ? t(:new_points) : t(:no_points)})</span>"
    end
  end
end