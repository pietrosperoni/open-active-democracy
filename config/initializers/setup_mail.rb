ActionMailer::Base.smtp_settings = {  
  :address              => "localhost",  
  :enable_starttls_auto => false
} 


if Rails.env.development?
  class DevelopmentMailInterceptor  
    def self.delivering_email(message)  
      message.subject = "#{message.to} #{message.subject}"
      message.to = "root@localhost"
      #message.bcc = "robert@localhost"
    end  
  end

  Mail.register_interceptor(DevelopmentMailInterceptor)
elsif Rails.env.production?
  class DevelopmentMailInterceptor  
    def self.delivering_email(message)  
      #message.subject = "#{message.to} #{message.subject}"
      #message.to = "robert@ibuar.is,gunnar@ibuar.is,dmj@hi.is"
      message.bcc = "robert@ibuar.is,gunnar@ibuar.is,hinrik@hugsmidi.is"
    end  
  end

  Mail.register_interceptor(DevelopmentMailInterceptor)
end