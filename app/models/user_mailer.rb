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
    @notification = n
    @sender = sender
    @n = n.to_s.underscore
    RAILS_DEFAULT_LOGGER.info("Notification class: #{@n}")
    @notifiable = notifiable
    if @n.include?("notification_warning")
      @subject = "Viðvörun frá vidraedur.is"
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
    @subject = "Skýrsla frá vidraedur.is"
  end
  
  def new_question(question,admin=true)
    tag = Tag.find_by_name(question.cached_issue_list)
    if admin
      QUESTION_EMAILS_SETUP.each do |email_setup|
        if tag and email_setup[0].include?(tag.external_id)
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
    else
      @recipients  = question.user.email 
      @subject = "Þín innsend spurning - vidraedur.is"
    end
    @from        = "#{Government.last.name} <#{Government.last.email}>"
    headers        "Reply-to" => Government.last.email
    @sent_on     = Time.now
    @content_type = "text/html"
    @body[:root_url] = 'http://' + Government.last.base_url + '/'
    @body[:admin] = admin
    @question = question
    @tag = tag
    @admin = admin
  end

  def question_answer(question)
    tag = Tag.find_by_name(question.cached_issue_list)
    @recipients  = question.user.email 
    @subject = "Svar við spurningu - vidraedur.is"
    @from        = "#{Government.last.name} <#{Government.last.email}>"
    headers        "Reply-to" => Government.last.email
    @sent_on     = Time.now
    @content_type = "text/html"
    @body[:root_url] = 'http://' + Government.last.base_url + '/'
    @question = question
    @tag = tag
  end

  def new_document(document,admin=true)
    tag = Tag.find_by_name(document.cached_issue_list)
    if admin
      QUESTION_EMAILS_SETUP.each do |email_setup|
        if tag and email_setup[0].include?(tag.external_id)
          @recipients  = email_setup[1]   
          break
        end
      end
      unless @recipients
        @recipients  = "robert@ibuar.is,gunnar@ibuar.is" 
        @subject = "Error in sending new document email"
      else
        @subject = "Nýtt erindi frá vidraedur.is"
      end
    else
      @recipients  = document.user.email 
      @subject = "Þitt innsenda erindi - vidraedur.is"
    end
    @from        = "#{Government.last.name} <#{Government.last.email}>"
    headers        "Reply-to" => Government.last.email
    @sent_on     = Time.now
    @content_type = "text/html"
    @body[:root_url] = 'http://' + Government.last.base_url + '/'
    @body[:admin] = admin
    @document = document
    @tag = tag
    @admin = admin
  end
  
  protected
    def setup_notification(user)
      @recipients  = "#{user.login} <#{user.email}>"
      @from        = "#{Government.last.name} <#{Government.last.email}>"
      headers        "Reply-to" => Government.last.email
      @sent_on     = Time.now
      @content_type = "text/html"      
      @body[:root_url] = 'http://' + Government.last.base_url + '/'
    end    
        
end
