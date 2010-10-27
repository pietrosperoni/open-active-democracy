require 'questions_email_setup'

class UserMailer < ActionMailer::Base
  
  # action mailer docs: http://api.rubyonrails.com/classes/ActionMailer/Base.html
  
  def welcome(user)
    @recipients  = "#{user.real_name.titleize} <#{user.email}>"
    @from        = "#{Government.last.name} <#{Government.last.admin_email}>"
    headers        "Reply-to" => Government.last.admin_email
    @sent_on     = Time.now
    @content_type = "text/plain"      
    @subject = EmailTemplate.fetch_subject_liquid("welcome").render({'government' => Government.last, 'user' => user}, :filters => [LiquidFilters])
    @body = EmailTemplate.fetch_liquid("welcome").render({'government' => Government.last, 'user' => user}, :filters => [LiquidFilters])
  end
  
  def invitation(user,sender_name,to_name,to_email)
    @recipients = ""
    @recipients += to_name + ' ' if to_name
    @recipients += '<' + to_email + '>'
    @from        = "#{Government.last.admin_name} <#{Government.last.admin_email}>"
    headers        "Reply-to" => Government.last.admin_email
    @sent_on = Time.now
    @content_type = "text/plain"      
    @subject = EmailTemplate.fetch_subject_liquid("invitation").render({'government' => Government.last, 'user' => user, 'sender_name' => sender_name, 'to_name' => to_name, 'to_email' => to_email}, :filters => [LiquidFilters])    
    @body = EmailTemplate.fetch_liquid("invitation").render({'government' => Government.last, 'user' => user, 'sender_name' => sender_name, 'to_name' => to_name, 'to_email' => to_email}, :filters => [LiquidFilters])    
  end  

  def new_password(user,new_password) 
    setup_notification(user) 
    @subject = EmailTemplate.fetch_subject_liquid("new_password").render({'government' => Government.last, 'user' => user}, :filters => [LiquidFilters])
    @body = EmailTemplate.fetch_liquid("new_password").render({'government' => Government.last, 'user' => user, 'new_password' => new_password}, :filters => [LiquidFilters])
  end  
  
  def notification(n,sender,recipient,notifiable)
    setup_notification(recipient)    
    @subject = EmailTemplate.fetch_subject_liquid(n.class.to_s.underscore).render({'government' => Government.last, 'recipient' => recipient, 'sender' => sender, 'notifiable' => notifiable, 'notification' => n}, :filters => [LiquidFilters])    
    @body = EmailTemplate.fetch_liquid(n.class.to_s.underscore).render({'government' => Government.last, 'recipient' => recipient, 'sender' => sender, 'notifiable' => notifiable, 'notification' => n}, :filters => [LiquidFilters])
  end  
  
  def new_question(question)
    tag = Tag.find_by_name(question.cached_issue_list)
    QUESTION_EMAILS_SETUP.each do |email_setup|
      if email_setup[0].include?(tag.external_id)
        @recipients  = email_setup[1]   
        break
      end
    end
    unless @recipients
      @recipients  = "robert@ibuar.is,gunnar@ibuar.is" 
      @subject = "Error in sending new question email"
    else
      @subject = "Ný spurning frá vidraedur.is"
    end
    @from        = "#{Government.last.name} <#{Government.last.email}>"
    headers        "Reply-to" => Government.last.email
    @sent_on     = Time.now
    @content_type = "text/plain"
    @body[:root_url] = 'http://' + Government.last.base_url + '/'
    @question = question
  end

  protected
    def setup_notification(user)
      @recipients  = "#{user.real_name.titleize} <#{user.email}>"
      @from        = "#{Government.last.name} <#{Government.last.email}>"
      headers        "Reply-to" => Government.last.email
      @sent_on     = Time.now
      @content_type = "text/plain"      
      @body[:root_url] = 'http://' + Government.last.base_url + '/'
    end    
        
end
