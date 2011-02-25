class UserMailer < ActionMailer::Base
  
  # action mailer docs: http://api.rubyonrails.com/classes/ActionMailer/Base.html
  
  def new_nation(govt,user)
    @recipients  = "#{user.login} <#{user.email}>"
    @from        = "Jim Gilliam <jim@gilliam.com>"
    headers        "Reply-to" => "jim@gilliam.com"
    @sent_on     = Time.now
    @subject = "Your nation is ready"
    @content_type = "text/plain"
    @body[:govt] = govt
    @body[:user] = user
  end
  
  def welcome(user)
    @recipients  = "#{user.real_name.titleize} <#{user.email}>"
    @from        = "#{Government.current.name} <#{Government.current.admin_email}>"
    headers        "Reply-to" => Government.current.admin_email
    @sent_on     = Time.now
    @content_type = "text/plain"      
    @subject = "WELCOME DRAFT" #EmailTemplate.fetch_subject_liquid("welcome").render({'government' => Government.current, 'user' => user, 'partner' => Partner.current}, :filters => [LiquidFilters])
    @body = "DRAFT" #EmailTemplate.fetch_liquid("welcome").render({'government' => Government.current, 'user' => user}, :filters => [LiquidFilters])
  end
  
  def invitation(user,sender_name,to_name,to_email)
    @recipients = ""
    @recipients += to_name + ' ' if to_name
    @recipients += '<' + to_email + '>'
    @from        = "#{Government.current.admin_name} <#{Government.current.admin_email}>"
    headers        "Reply-to" => Government.current.admin_email
    @sent_on = Time.now
    @content_type = "text/plain"      
    @subject = "INVITATION DRAFT" #EmailTemplate.fetch_subject_liquid("invitation").render({'government' => Government.current, 'user' => user, 'sender_name' => sender_name, 'to_name' => to_name, 'to_email' => to_email}, :filters => [LiquidFilters])    
    @body = "DRAFT" #EmailTemplate.fetch_liquid("invitation").render({'government' => Government.current, 'user' => user, 'sender_name' => sender_name, 'to_name' => to_name, 'to_email' => to_email}, :filters => [LiquidFilters])    
  end  

  def new_password(user,new_password) 
    setup_notification(user) 
    @subject = "" #EmailTemplate.fetch_subject_liquid("new_password").render({'government' => Government.current, 'user' => user}, :filters => [LiquidFilters])
    @body = "" #EmailTemplate.fetch_liquid("new_password").render({'government' => Government.current, 'user' => user, 'new_password' => new_password}, :filters => [LiquidFilters])
  end  
  
  def notification(n,sender,recipient,notifiable)
    setup_notification(recipient)
    @notification = n
    @sender = sender
    @government = Government.last
    @n = n.to_s.underscore
    Rails.logger.info("Notification class: #{@n}")
    @notifiable = notifiable
    if @n.include?("notification_warning")
      @subject = I18n.t(:email_subject_warning_from_website)
    elsif @n.include?("notification_comment_flagged") 
      @subject = @notification.name
    end
    @recipient = recipient
  end
  
  def report(user,priorities,questions,documents,treaty_documents)
    @recipients  = "#{user.login} <#{user.email}>"
    @from        = "#{Government.last.name} <#{Government.last.email}>"
    headers        "Reply-to" => Government.last.email
    @sent_on     = Time.now
    @content_type = "text/html"
    @priorities = priorities
    @questions = questions
    @documents = documents
    @treaty_documents = treaty_documents
    @subject = I18n.t(:email_subject_report_from_website)
  end
  
  protected
    def setup_notification(user)
      @recipients  = "#{user.login} <#{user.email}>"
      @from        = "#{Government.current.name} <#{Government.current.email}>"
      headers        "Reply-to" => Government.current.email
      @sent_on     = Time.now
      @content_type = "text/html"     
      @body[:root_url] = 'http://' + Government.current.base_url + '/'
    end    
        
end
