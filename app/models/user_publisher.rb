class UserPublisher
  def self.create_comment(current_facebook_user, comment, activity)
    priority = activity.priority if activity.has_priority?
    if activity.has_question?
      object_url = activity.question.show_url
      object_name = activity.question.name
    elsif activity.has_document?
      object_url = activity.document.show_url
      object_name = activity.document.name
    elsif activity.has_priority?
      object_url = activity.priority.show_url
      object_name = activity.priority.name
    else
      object_url = comment.show_url
      object_name = activity.name
    end
    name = "#{object_name}"
    description = comment.content
    current_facebook_user.fetch
    current_facebook_user.feed_create(
    Mogli::Post.new(:name => name,
                    :link=>object_url,
                    :description=>description))
  end

  def self.create_question(current_facebook_user, question)
    name = "Spurning: #{question.name}"
    description = "#{question.content}"
    current_facebook_user.fetch
    current_facebook_user.feed_create(
    Mogli::Post.new(:name => name,
                    :link=>question.show_url,
                    :description=>description))
  end

  def self.create_priority(current_facebook_user, priority)
    name = "#{priority.name}"
    description = "#{priority.description}"
    current_facebook_user.fetch
    current_facebook_user.feed_create(
    Mogli::Post.new(:name => name,
                    :link=>priority.show_url,
                    :description=>description))
  end

  
  def self.create_document(current_facebook_user, document)
    name = "Erindi: #{document.name}"
    description = "#{document.content}"
    current_facebook_user.fetch
    current_facebook_user.feed_create(
    Mogli::Post.new(:name => name,
                    :link=>document.show_url,
                    :description=>description))    
  end  
end
