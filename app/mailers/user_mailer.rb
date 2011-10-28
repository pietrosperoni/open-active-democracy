class UserMailer < ActionMailer::Base
    
  helper :application
    
  def welcome(user)
    @recipient = @user = user
    @government = Government.current
    recipients  = "#{user.real_name.titleize} <#{user.email}>"
    attachments.inline['logo.png'] = get_conditional_logo
    mail :to=>recipients,
         :reply_to => Government.current.admin_email,
         :from => "#{tr(Government.current.name,"Name from database")} <#{Government.current.admin_email}>",
         :subject=>tr("Thank you for registering at {government_name}","email", :government_name => tr(Government.current.name,"Name from database")) do |format|
           format.text { render :text=>convert_to_text(render_to_string("welcome.html")) }
           format.html
         end
  end

  def priority_status_message(priority, status, status_message, user)
    @priority = priority
    @government = Government.current
    @status = status
    @message = status_message
    attachments.inline['logo.png'] = get_conditional_logo

    @recipient = @user = user
    recipient = "#{user.real_name.titleize} <#{user.email}>"
    mail to:       recipient,
         reply_to: Government.current.admin_email,
         from:     "#{tr(Government.current.name,"Name from database")} <#{Government.current.admin_email}>",
         subject:  tr('The priority "{priority}" has been updated"', "email", :priority => priority.name) do |format|
      format.text { render text: convert_to_text(render_to_string("priority_status_message.html")) }
      format.html
    end
  end

  def invitation(user,sender_name,to_name,to_email)
    @sender = @recipient = @user = user
    @government = Government.current
    @sender_name = sender_name
    @to_name = to_name
    @to_email = to_email
    @recipients = ""
    @recipients += to_name + ' ' if to_name
    @recipients += '<' + to_email + '>'
    attachments.inline['logo.png'] = get_conditional_logo
    mail :to => @recipients,
         :reply_to => Government.current.admin_email,
         :from => "#{tr(Government.current.name,"Name from database")} <#{Government.current.admin_email}>",
         :subject => tr("Invitation from {sender_name} to join {government_name}","email", :sender_name=>sender_name, :government_name => tr(Government.current.name,"Name from database")) do |format|
           format.text { render :text=>convert_to_text(render_to_string("invitation.html")) }
           format.html
         end
  end  

  def new_password(user,new_password)
    @recipient = @user = user
    @new_password = new_password
    @government = Government.current
    recipients  = "#{user.real_name.titleize} <#{user.email}>"
    attachments.inline['logo.png'] = get_conditional_logo
    mail :to=>recipients,
         :reply_to => Government.current.admin_email,
         :from => "#{tr(Government.current.name,"Name from database")} <#{Government.current.admin_email}>",
         :subject => tr("Your new temporary password","email") do |format|
           format.text { render :text=>convert_to_text(render_to_string("new_password.html")) }
           format.html
         end
  end
  
  def notification(n,sender,recipient,notifiable)
    @n = @notification = n
    @sender = sender
    @government = Government.current
    user = @user = @recipient = recipient
    @notifiable = notifiable
    Rails.logger.info("Notification class: #{@n} #{@n.class.to_s}  #{@n.inspect} notifiable: #{@notifiable}")
    recipients  = "#{user.real_name.titleize} <#{user.email}>"
    attachments.inline['logo.png'] = get_conditional_logo
    Rails.logger.info("Notification class: #{@n} #{@n.class.to_s}")
    mail :to => recipients,
         :reply_to => Government.current.admin_email,
         :from => "#{tr(Government.current.name,"Name from database")} <#{Government.current.admin_email}>",
         :subject => @notification.name do |format|
      format.text { render :text=>convert_to_text(render_to_string("user_mailer/notifications/#{@n.class.to_s.underscore}.html")) }      
      format.html { render "user_mailer/notifications/#{@n.class.to_s.underscore}" }
    end
  end
  
  def report(user,priorities,questions,documents,treaty_documents)
    @government = Government.current
    @recipients  = "#{user.login} <#{user.email}>"
    @from        = "#{tr(Government.current.name,"Name from database")} <#{Government.current.email}>"
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
      @from        = "#{tr(Government.current.name,"Name from database")} <#{Government.current.email}>"
      headers        "Reply-to" => Government.current.email
      @sent_on     = Time.now
      @content_type = "text/html"     
      @body[:root_url] = 'http://' + Government.current.base_url_w_partner + '/'
    end

  private

    def get_conditional_logo
      if @government.layout.include?("better_reykjavik")
        File.read(Rails.root.join("public/images/logos/BR_email.png"))
      else
        File.read(Rails.root.join("public/images/logos/YourPriorities_large.png"))
      end
    end

    # Returns the text in UTF-8 format with all HTML tags removed
    # From: https://github.com/jefflab/mail_style/tree/master/lib
    # TODO:
    #  - add support for DL, OL
    def convert_to_text(html, line_length = 65, from_charset = 'UTF-8')
      txt = html

      # decode HTML entities
      he = HTMLEntities.new
      begin
        txt = he.decode(txt)
      rescue
        txt = txt
      end

      # handle headings (H1-H6)
      txt.gsub!(/[ \t]*<h([0-9]+)[^>]*>(.*)<\/h[0-9]+>/i) do |s|
        hlevel = $1.to_i
        # cleanup text inside of headings
        htext = $2.gsub(/<\/?[^>]*>/i, '').strip
        hlength = (htext.length > line_length ?
                    line_length :
                    htext.length)

        case hlevel
          when 1   # H1, asterisks above and below
            ('*' * hlength) + "\n" + htext + "\n" + ('*' * hlength) + "\n"
          when 2   # H1, dashes above and below
            ('-' * hlength) + "\n" + htext + "\n" + ('-' * hlength) + "\n"
          else     # H3-H6, dashes below
            htext + "\n" + ('-' * htext.length) + "\n"
        end
      end

      # links
      txt.gsub!(/<a.*href=\"([^\"]*)\"[^>]*>(.*)<\/a>/i) do |s|
        $2.strip + ' ( ' + $1.strip + ' )'
      end

      # lists -- TODO: should handle ordered lists
      txt.gsub!(/[\s]*(<li[^>]*>)[\s]*/i, '* ')
      # list not followed by a newline
      txt.gsub!(/<\/li>[\s]*(?![\n])/i, "\n")

      # paragraphs and line breaks
      txt.gsub!(/<\/p>/i, "\n\n")
      txt.gsub!(/<br[\/ ]*>/i, "\n")

      # strip remaining tags
      txt.gsub!(/<\/?[^>]*>/, '')

      # wrap text
#      txt = r.format(('[' * line_length), txt)

      # remove linefeeds (\r\n and \r -> \n)
      txt.gsub!(/\r\n?/, "\n")

      # strip extra spaces
#      txt.gsub!(/\302\240+/, " ") # non-breaking spaces -> spaces
      txt.gsub!(/\n[ \t]+/, "\n") # space at start of lines
      txt.gsub!(/[ \t]+\n/, "\n") # space at end of lines

      # no more than two consecutive newlines
      txt.gsub!(/[\n]{3,}/, "\n\n")

      txt.strip
    end          
end
