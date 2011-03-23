
class DevelopmentMailInterceptor  
  def self.delivering_email(message)  
    message.subject = "[#{message.to}] #{message.subject}"  
    message.to = "robert"  
  end  
end

if Rails.env.development?
  ActionMailer::Base.smtp_settings = {  
    :address              => "localhost",  
    :enable_starttls_auto => false
  } 
  Mail.register_interceptor(DevelopmentMailInterceptor)
end