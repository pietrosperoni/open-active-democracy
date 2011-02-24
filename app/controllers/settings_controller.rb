class SettingsController < ApplicationController
  
  before_filter :login_required
  before_filter :get_user

  # GET /settings
  def index
    @partners = Partner.find(:all, :conditions => "is_optin = true and status = 'active' and id <> 3")
    @page_title = t('settings.index.title', :government_name => current_government.name)
  end

  # PUT /settings
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = t('settings.saved')
        format.html { 
          redirect_to(settings_url) 
        }
      else
        format.html { render :action => "index" }
      end
    end
  end

  # GET /settings/signups
  def signups
    @page_title = t('settings.notifications.title', :government_name => current_government.name)
    @rss_url = url_for(:only_path => false, :controller => "rss", :action => "your_notifications", :format => "rss", :c => current_user.rss_code)
    @partners = Partner.find(:all, :conditions => "is_optin = true and status = 'active' and id <> 3")
  end

  # GET /settings/picture
  def picture
    @page_title = t('settings.picture.title')
  end

  def picture_save
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        ActivityUserPictureNew.create(:user => @user)   
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
