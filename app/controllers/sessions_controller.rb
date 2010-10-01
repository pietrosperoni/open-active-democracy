# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  def create
    RAILS_DEFAULT_LOGGER.debug("BLAH -5: #{session[:return_to]}")
    self.current_user = User.authenticate_from_rsk(params[:token], request)
    RAILS_DEFAULT_LOGGER.debug("User Return #{self.current_user}")
    redirect_to :login_error unless logged_in?
    respond_to do |format|
      format.html {
        if logged_in?
          if params[:remember_me] == "1"
            current_user.remember_me unless current_user.remember_token?
            cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
          end
          redirect_back_or_default('/')
          flash[:notice] = t('sessions.create.success', :user_name => current_user.name)
        else
          flash[:error] = t('sessions.create.failed')
          render :action => 'login_error'
        end          
      }
    end
  end

  def login_to_rsk_auth
    store_previous_location
    redirect_to DB_CONFIG[RAILS_ENV]['rsk_url']
  end
  
  def login_error    
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session    
    flash[:notice] = t('sessions.destroy')
    redirect_back_or_default('/')
  end 
end
