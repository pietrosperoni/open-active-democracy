module PrioritiesHelper  
  def get_questions_number_text(questions_count, total_points,new_points=false)
    if questions_count>0
      "<span style=\"color:#666;font-size:0.75em;\">(#{questions_count} af #{total_points})</span>"
    else
      "<span style=\"color:#666;font-size:0.75em;\">(#{new_points ? t(:new_points) : t(:no_points)})</span>"
    end
  end
end