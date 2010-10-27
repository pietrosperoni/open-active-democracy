# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem
  include FaceboxRender

  include Facebooker2::Rails::Controller

  require_dependency "activity.rb"

#  rescue_from ActionController::InvalidAuthenticityToken, :with => :bad_token

  helper :all # include all helpers, all the time
  
  helper_method :facebook_session, :government_cache, :current_government, :current_tags, :facebook_session, :is_robot?, :js_help
  
  before_filter :show_login_status

  before_filter :check_if_email_is_set
  skip_before_filter :check_if_email_is_set, :only=>["set_email"]

  before_filter :load_actions_to_publish, :unless => [:is_robot?]
  before_filter :check_facebook, :unless => [:is_robot?]
    
  before_filter :check_suspension, :unless => [:is_robot?]
  before_filter :update_loggedin_at, :unless => [:is_robot?]
  
  before_filter :check_for_reset_filters
  
  filter_parameter_logging :password, :password_confirmation

  layout :get_layout

  protected

  def show_login_status
    if logged_in?
      RAILS_DEFAULT_LOGGER.info("Logged in as #{current_user.name}")
    else
      RAILS_DEFAULT_LOGGER.info("Not logged in")
    end
  end

  def redirect_if_not_logged_in
    store_location
    unless logged_in?
      if RAILS_ENV=="development"
        current_user = User.first
      else
        redirect_to DB_CONFIG[RAILS_ENV]['rsk_url']
      end
    end
  end

  def check_if_email_is_set
    RAILS_DEFAULT_LOGGER.debug(action_name)
    if logged_in?
      unless current_user.email
        redirect_to "/set_email"
        return false
      end
    end
    return true
  end
  
  def check_for_reset_filters
    if params[:r]
      session[:priorities_subfilter]=nil
      session[:selected_tag_name]=nil
      session[:questions_subfilter]="answered"
    end
  end
  
  def get_layout
    return "esb"
  end

  def current_government
    if RAILS_ENV=="development"
      self.current_user = User.last
    end
    @current_government = Government.last
    return @current_government
  end
  
  def current_tags
    return [] unless current_government.is_tags?
    @current_tags ||= Rails.cache.fetch('Tag.by_endorsers_count.all') { Tag.by_endorsers_count.all }
  end

  def load_actions_to_publish
    @user_action_to_publish = flash[:user_action_to_publish] 
    flash[:user_action_to_publish]=nil
  end  
  
  def check_suspension
    if logged_in? and current_user and current_user.status == 'suspended'
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      redirect_to "/bann"
      return false
    end
  end
  
  # they were trying to endorse a priority, so let's go ahead and add it and take htem to their priorities page immediately    
  def check_priority
    return unless logged_in? and session[:priority_id]
    @priority = Priority.find(session[:priority_id])
    @value = session[:value].to_i
    session[:priority_id] = nil
    session[:value] = nil
  end
  
  def update_loggedin_at
    return unless logged_in?
    return unless current_user.loggedin_at.nil? or Time.now > current_user.loggedin_at+30.minutes
    User.retry_mysql_error do
      User.find(current_user.id).update_attribute(:loggedin_at,Time.now)
    end
  end

   def process_display_array(activities)
    unless activities.empty?
      class_type=activities.first.class
      found_array = Rails.cache.read("dl_#{session[:session_id]}_#{class_type}")
      if found_array
        activities = activities.delete_if {|a| found_array.include?(a.id)}
        write_array = (found_array+activities.map {|x| x.id}).uniq
      else
        write_array = activities.map {|x| x.id}
      end
      if found_array!=write_array
        Rails.cache.write("dl_#{session[:session_id]}_#{class_type}", write_array, :expires_in => 12.hours)
      end
    end
    activities
  end
  
  def reset_displayed_array(activities)
    unless activities.empty?
      class_type=activities.first.class
      Rails.cache.write("dl_#{session[:session_id]}_#{class_type}", activities.map {|x| x.id}, :expires_in => 12.hours) 
    end
  end

  def check_facebook
    if logged_in? and current_facebook_user
      @user = User.find(current_user.id)
      if not @user.update_with_facebook(current_facebook_user.id)
        return
      end
      if not @user.activated?
        @user.activate!
      end      
      @current_user = User.find(current_user.id)
    end
  end

  def is_robot?
    return true if request.format == 'rss' or params[:controller] == 'pictures'
    request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
  end
  
  def no_facebook?
    return false
  end
  
  def bad_token
    flash[:error] = t('application.bad_token')
    respond_to do |format|
      format.html { redirect_to request.referrer||'/' }
      format.js { redirect_from_facebox(request.referrer||'/') }
    end
  end
  
  def fb_session_expired
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session    
    flash[:error] = t('application.fb_session_expired')
    respond_to do |format|
      format.html { redirect_to '/' }
      format.js { redirect_from_facebox(request.referrer||'/') }
    end    
  end
  
  def js_help
    JavaScriptHelper.instance
  end

  class JavaScriptHelper
    include Singleton
    include ActionView::Helpers::JavaScriptHelper
  end  
  
end

module FaceboxRender
   
  def render_to_facebox( options = {} )
    options[:template] = "#{default_template_name}" if options.empty?

    action_string = render_to_string(:action => options[:action], :layout => "facebox") if options[:action]
    template_string = render_to_string(:template => options[:template], :layout => "facebox") if options[:template]

    render :update do |page|
      page << "jQuery.facebox(#{action_string.to_json})" if options[:action]
      page << "jQuery.facebox(#{template_string.to_json})" if options[:template]
      page << "jQuery.facebox(#{(render :partial => options[:partial]).to_json})" if options[:partial]
      page << "jQuery.facebox(#{options[:html].to_json})" if options[:html]

      if options[:msg]
        page << "jQuery('#facebox .content').prepend('<div class=\"message\">#{options[:msg]}</div>')"
      end
      page << render(:partial => "shared/javascripts_reloadable")
      
      yield(page) if block_given?

    end
  end
    
end