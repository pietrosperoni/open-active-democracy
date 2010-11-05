class SettingsController < ApplicationController
  
  layout "esb_no_chapters"
  
  before_filter :login_required
  before_filter :get_user

  # GET /settings
  def index
    redirect_to :action=>"picture"
  end

  # PUT /settings
  def update
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = t('settings.saved')
        format.html { render :action => "picture" }
      else
        format.html { render :action => "picture" }
      end
    end
  end

  # GET /settings/signups
  def signups
    @page_title = t('settings.notifications.title', :government_name => current_government.name)
    @rss_url = url_for(:only_path => false, :controller => "rss", :action => "your_notifications", :format => "rss", :c => current_user.rss_code)
  end

  # GET /settings/picture
  def picture
    @user = current_user
    @page_title = t('settings.picture.title')
  end

  def picture_destroy
    @user = current_user
    @user.buddy_icon = nil
    @user.save(false)
    redirect_to :action => "picture"
  end

  def picture_save    
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = t('pictures.success')
        format.html { redirect_to(:action => :picture) }
      else
        format.html { render :action => "picture" }
      end
    end
  end
    
  # GET /settings/delete
  def delete
    @page_title = t('settings.delete.title', :government_name => current_government.name)
  end

  # DELETE /settings
  def destroy
    @user.delete!
    self.current_user.forget_me
    cookies.delete :auth_token
    reset_session    
    flash[:notice] = t('settings.destroy')
    redirect_to "/" and return
  end

  private
  def get_user
    @user = User.find(current_user.id)
  end

end
