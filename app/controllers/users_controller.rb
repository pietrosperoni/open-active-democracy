class UsersController < ApplicationController

  before_filter :login_required, :only => [:resend_activation, :follow, :unfollow, :endorse, :subscriptions, :disable_facebook]
  before_filter :current_user_required, :only => [:resend_activation]
  before_filter :admin_required, :only => [:suspend, :unsuspend, :impersonate, :edit, :update, :signups, :legislators, :legislators_save, :make_admin, :reset_password, :show]
  skip_before_filter :check_if_email_is_set, :only=>["set_email"]
  
  def index
    if params[:q]
      @users = User.active.find(:all, :conditions => ["login LIKE ?", "#{h(params[:q])}%"], :order => "users.login asc")
    else
      @users = User.active.by_ranking.paginate :page => params[:page], :per_page => params[:per_page]  
    end
    respond_to do |format|
      format.html { redirect_to :controller => "network" }
      format.js { render :text => @users.collect{|p|p.login}.join("\n") }
      format.xml { render :xml => @users.to_xml(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @users.to_json(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  def disable_facebook
#    @user = current_user
#    @user.facebook_uid=nil
#    @user.save(false)
#    fb_cookie_destroy
    redirect_to '/'
  end
  
  def set_email
    @user = current_user
    flash[:notice]=nil
    if request.put?
      @user.email = params[:user][:email]
      @user.have_sent_welcome = true
      if @user.save
        @user.send_welcome
        redirect_back_or_default('/')
      else
        flash[:notice]="Töluvpóstfang ekki samþykkt"
        redirect_to "/set_email"
      end
    end
  end
  
  def subscriptions
    @subscription_user = current_user
    if request.put?
      TagSubscription.delete_all(["user_id = ?",current_user.id])
      Tag.all.each do |tag|
        tag_checkbox_id = "subscribe_to_tag_id_#{tag.id}"
        if params[:user][tag_checkbox_id]
          subscription = TagSubscription.new
          subscription.user_id = current_user.id
          subscription.tag_id = tag.id
          subscription.save
        end
      end
      RAILS_DEFAULT_LOGGER.info("Starting HASH #{params[:user].inspect}")
      params[:user].each do |hash_value,x|
        RAILS_DEFAULT_LOGGER.info(hash_value)
        if hash_value.include?("to_tag_id")
          RAILS_DEFAULT_LOGGER.info("DELETING: #{hash_value}")
          params[:user].delete(hash_value)
        end
      end
      RAILS_DEFAULT_LOGGER.info("After HASH #{params[:user].inspect}")
      current_user.update_attributes(params[:user])
      current_user.save
      redirect_to "/"
    end
  end
  
  # render new.rhtml
  def new
    @user = User.new(:branch => current_government.default_branch) if current_government.is_branches?
    if logged_in?
      redirect_to "/"
      return
    end
    store_previous_location
    respond_to do |format|
      format.html
    end
  end
  
  def edit
    @user = User.find(params[:id])
    redirect_to '/' and return if check_for_suspension
    @page_title = t('users.edit.title', :user_name => @user.name)
  end
  
  def update
    @user = User.find(params[:id])
    @page_title = t('users.edit.title', :user_name => @user.name)
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = t('users.edit.saved', :user_name => @user.name)
        @page_title = t('users.edit.title', :user_name => @user.name)
        format.html { redirect_to @user }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  def signups
    @user = User.find(params[:id])
    redirect_to '/' and return if check_for_suspension
    @page_title = t('users.signups.title', :user_name => @user.name)
    @rss_url = url_for(:only_path => false, :controller => "rss", :action => "your_notifications", :format => "rss", :c => @user.rss_code)
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    redirect_to '/' and return if check_for_suspension
    @page_title = t('users.show.title', :user_name => @user.name, :government_name => current_government.name)
    @activities = @user.activities.active.by_recently_created.paginate :include => :user, :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html
      format.xml { render :xml => @user.to_xml(:methods => [:revisions_count], :include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @user.to_json(:methods => [:revisions_count], :include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end
  
  def priorities
    @user = User.find(params[:id])    
    redirect_to '/' and return if check_for_suspension
    @page_title = t('users.priorities.title', :user_name => @user.name.possessive, :government_name => current_government.name)
    @priorities = @user.endorsements.active.paginate :include => :priority, :page => params[:page], :per_page => params[:per_page]  
    @endorsements = nil
    get_following
    if logged_in? # pull all their endorsements on the priorities shown
      @endorsements = Endorsement.find(:all, :conditions => ["priority_id in (?) and user_id = ? and status='active'", @priorities.collect {|c| c.priority_id},current_user.id])
    end    
    respond_to do |format|
      format.html
      format.xml { render :xml => @priorities.to_xml(:include => [:priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @priorities.to_json(:include => [:priority], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  def activities
    @user = User.find(params[:id])
    redirect_to '/' and return if check_for_suspension
    get_following
    @page_title = t('users.activities.title', :user_name => @user.name, :government_name => current_government.name)
    @activities = @user.activities.active.by_recently_created.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html # show.html.erb
      format.rss { render :template => "rss/activities" }
      format.xml { render :xml => @activities.to_xml(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  def comments
    @user = User.find(params[:id])
    redirect_to '/' and return if check_for_suspension
    @page_title = t('users.comments.title', :user_name => @user.name.possessive, :government_name => current_government.name)
    @comments = @user.comments.published.by_recently_created.find(:all, :include => :activity).paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.rss { render :template => "rss/comments" }
      format.xml { render :xml => @comments.to_xml(:except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @comments.to_json(:except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
  
  def discussions
    @user = User.find(params[:id])
    redirect_to '/' and return if check_for_suspension
    get_following
    @page_title = t('users.discussions.title', :user_name => @user.name.possessive, :government_name => current_government.name)
    @activities = @user.activities.active.discussions.by_recently_created.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html { render :template => "users/activities" }
      format.xml { render :xml => @activities.to_xml(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end 
  
  def documents
    @user = User.find(params[:id])
    redirect_to '/' and return if check_for_suspension
    get_following
    @page_title = t('users.documents.title', :user_name => @user.name.possessive, :government_name => current_government.name)
    @documents = @user.documents.published.by_recently_updated.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html
      format.xml { render :xml => @documents.to_xml(:include => [:priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @documents.to_json(:include => [:priority], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @valid = true
    @user = User.new(params[:user]) 
    @user.request = request
    @user.referral = @referral
    begin
      @user.save! #save first
      rescue ActiveRecord::RecordInvalid
        @valid = false    
    end
    
    if not @valid # if it's not valid, punt on all the rest
      respond_to do |format|
        format.js
        format.html { render :text => "error", :status => 500}
      end
      return
    end
    self.current_user = @user # automatically log them in
    
      
    flash[:notice] = t('users.new.success', :government_name => current_government.name)
    if session[:query] 
      @send_to_url = "/?q=" + session[:query]
      session[:query] = nil
    else
      @send_to_url = session[:return_to] || get_previous_location
    end
    session[:goal] = 'signup'
    respond_to do |format|
      format.js
      format.html { render :text => "error", :status => 500}
    end      
  end  

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate!
    end
    flash[:notice] = t('users.activate.success')
    if logged_in? and current_government.is_legislators?
      redirect_to legislators_settings_url
    else
      redirect_back_or_default('/')
    end
  end
  
  def resend_activation
    @user = User.find(params[:id])
    redirect_to '/' and return if check_for_suspension
    @user.resend_activation
    flash[:notice] = t('users.activate.resend', :email => @user.email)
    redirect_back_or_default(url_for(@user))
  end  

  def reset_password
    @user = User.find(params[:id])
    @user.reset_password
    flash[:notice] = t('passwords.new.sent', :email => @user.email)
    redirect_to @user
  end
  
  # PUT /users/1/suspend
  def suspend
    @user = User.find(params[:id])
    @user.suspend! 
    redirect_to(@user)
  end

  # PUT /users/1/unsuspend
  def unsuspend
    @user = User.find(params[:id])
    @user.unsuspend! 
    flash[:notice] = t('users.reinstated', :user_name => @user.name)
    redirect_to(@user)
  end

  def impersonate
    @user = User.find(params[:id])
    self.current_user = @user
    flash[:notice] = t('admin.impersonate', :user_name => @user.name)
    redirect_to @user
    return
  end
  
  def make_admin
    @user = User.find(params[:id])
    @user.is_admin = true
    @user.save_with_validation(false)
    flash[:notice] = t('users.make_admin', :user_name => @user.name)
    redirect_to @user
  end
  
  private
  
    def check_for_suspension
      if @user.status == 'suspended'
        flash[:error] = t('users.suspended', :user_name => @user.name)
        if logged_in? and current_user.is_admin?
        else
          return true
        end
      end
      if @user.status == 'deleted'
        flash[:error] = t('users.deleted')
        return true
      end
    end
  
end
