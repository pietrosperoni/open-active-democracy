class UserMailer < ActionMailer::Base
    
  def welcome(user)
    @user = user
    @government = Government.current
    recipients  = "#{user.real_name.titleize} <#{user.email}>"
    mail(:to=>recipients,
         :reply_to => Government.current.admin_email,
         :from => "#{Government.current.name} <#{Government.current.admin_email}>",
         :subject=>tr("Thank you for registering at Your Priorities","email"))
  end
  
  def invitation(user,sender_name,to_name,to_email)
    @user = user
    @sender_name = sender_name
    @to_name = to_name
    @to_email = to_email
    @recipients = ""
    @recipients += to_name + ' ' if to_name
    @recipients += '<' + to_email + '>'
    mail(:to => @recipients,
         :reply_to => Government.current.admin_email,
         :from => "#{Government.current.name} <#{Government.current.admin_email}>",
         :subject => tr("Invitation from {{ sender_name }} to join Your Priorities","email", :sender_name=>sender_name))
  end  

  def new_password(user,new_password)
    @user = user
    @new_password = new_password
    recipients  = "#{user.real_name.titleize} <#{user.email}>"
    mail(:to=>recipients,
         :reply_to => Government.current.admin_email,
         :from => "#{Government.current.name} <#{Government.current.admin_email}>",
         :subject => tr("Your new password request","email"))
  end  
  
  def notification(n,sender,recipient,notifiable)
    @notification = n
    @sender = sender
    @government = Government.last
    @n = n.to_s.underscore
    @notifiable = notifiable
    Rails.logger.info("Notification class: #{@n}")
    recipients  = "#{user.real_name.titleize} <#{user.email}>"
    mail(:to => recipients,
         :reply_to => Government.current.admin_email,
         :from => "#{Government.current.name} <#{Government.current.admin_email}>",
         :subject => @notification.name) do |format|
      format.html { render "notifications/#{@n.class.to_s.underscore}" }
    end
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
  
#   def new_change_vote(sender,recipient,vote)
#     setup_notification(recipient)
#     @subject = "Your " + Government.current.name + " vote is needed: " + vote.change.priority.name
#     @body[:vote] = vote
#     @body[:change] = vote.change
#     @body[:recipient] = recipient
#     @body[:sender] = sender
#   end 
  
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
