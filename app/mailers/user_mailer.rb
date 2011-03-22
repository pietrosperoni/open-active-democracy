class UserMailer < ActionMailer::Base
  
#  default :from => "#{Government.current.name} <#{Government.current.admin_email}>", :reply_to => Government.current.admin_email
  
  def welcome(user)
    return
    @user = user
    @government = Government.current
    recipients  = "#{user.real_name.titleize} <#{user.email}>"
    mail(:to=>recipients, :subject=>tr("Thank you for registerring at #{Government.current.name}","email")) do
      format.html { render 'defaults/welcome'}
    end
  end
  
  def invitation(user,sender_name,to_name,to_email)
    return
    @recipients = ""
    @recipients += to_name + ' ' if to_name
    @recipients += '<' + to_email + '>'
    @from        = "#{Government.current.admin_name} <#{Government.current.admin_email}>"
    headers        "Reply-to" => Government.current.admin_email
    @sent_on = Time.now
    @content_type = "text/plain"      
    @subject = tr("Thank you for registerring at #{Government.current.name}","email")
    @body = "DRAFT" #EmailTemplate.fetch_liquid("invitation").render({'government' => Government.current, 'user' => user, 'sender_name' => sender_name, 'to_name' => to_name, 'to_email' => to_email}, :filters => [LiquidFilters])    
  end  

  def new_password(user,new_password) 
    return
    setup_notification(user) 
    @subject = "" #EmailTemplate.fetch_subject_liquid("new_password").render({'government' => Government.current, 'user' => user}, :filters => [LiquidFilters])
    @body = "" #EmailTemplate.fetch_liquid("new_password").render({'government' => Government.current, 'user' => user, 'new_password' => new_password}, :filters => [LiquidFilters])
  end  
  
  def notification(n,sender,recipient,notifiable)
    return
    setup_notification(recipient)
    @notification = n
    @sender = sender
    @government = Government.last
    @n = n.to_s.underscore
    Rails.logger.info("Notification class: #{@n}")
    @notifiable = notifiable
    if @n.include?("notification_warning")
      @subject = tr("Warning", "model/mailer")
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
    @subject = tr("Report", "model/mailer")
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
