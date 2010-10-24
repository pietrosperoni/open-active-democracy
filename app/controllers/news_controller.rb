class NewsController < ApplicationController

  before_filter :login_required, :except => [:index, :discussions, :questions, :activities]

  def index
    redirect_to :action => "activities"
    return
  end
  
  def discussions
    # 020910 commented_out_aom: @page_title = t('news.discussions.title', :government_name => current_government.name)
    # 020910 commented_out_aom: @rss_url = url_for(:only_path => false, :action => "comments", :format => "rss")
    if @current_government.users_count > 5000 # only show the last 7 days worth
      @activities = Activity.active.discussions.for_all_users.last_seven_days.by_recently_updated.paginate :page => params[:page], :per_page => 15
    else
      @activities = Activity.active.discussions.for_all_users.by_recently_updated.paginate :page => params[:page], :per_page => 15
    end
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.js { render :layout => false, :text => "document.write('" + js_help.escape_javascript(render_to_string(:layout => false, :template => 'activities/discussion_widget_small')) + "');" }          
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end 
  
  def comments
    # 020910 commented_out_aom: @page_title = t('news.comments.title', :government_name => current_government.name)
    @comments = Comment.published.last_three_days.by_recently_created.find(:all, :include => :activity).paginate :page => params[:page]
    respond_to do |format|
      format.rss { render :template => "rss/comments" }
      format.xml { render :xml => @comments.to_xml(:include => :user, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @comments.to_json(:include => :user, :except => NB_CONFIG['api_exclude_fields']) }
    end
  end
  
  def points
    # 020910 commented_out_aom: @page_title = t('news.points.title', :government_name => current_government.name, :briefing_name => current_government.briefing_name)
    @activities = Activity.active.questions_and_docs.for_all_users.paginate :page => params[:page]
    # 020910 commented_out_aom: @rss_url = url_for(:only_path => false, :format => "rss")
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.rss { render :template => "rss/activities" }       
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def activities
    if session[:priorities_subfilter] and session[:priorities_subfilter]=="mine" and current_user
      @activities = Activity.active.no_unanswered_questions.by_recently_created.by_user_id(current_user.id).paginate :page => params[:page], :per_page => params[:per_page]
    elsif session[:priorities_subfilter] and session[:priorities_subfilter]=="my_chapters" and current_user
      @activities =  Activity.active.no_unanswered_questions.by_recently_created.tagged_with(TagSubscription.find_all_by_user_id(current_user.id).collect {|sub| sub.tag.name},:on=>:issues).paginate :page => params[:page], :per_page => params[:per_page]
    elsif session[:selected_tag_name]
      @activities = Activity.active.no_unanswered_questions.for_all_users.by_recently_created.by_tag_name(session[:selected_tag_name]).paginate :page => params[:page], :per_page => params[:per_page]
    else
      @activities = Activity.active.no_unanswered_questions.for_all_users.by_recently_created.paginate :page => params[:page]
    end
    if request.format.js?
      @activities=process_display_array(@activities)
    else
      reset_displayed_array(@activities)
    end
    @rss_url = "/news/activities.rss"
    RAILS_DEFAULT_LOGGER.info(@activities)

    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.js {
        render :update do |page|
          unless @activities.empty?
            page.insert_html :top, "activities", render(:partial => "activity_list" )
            page << "FB.XFBML.parse(document.getElementById('activities'));"
          end
        end
      }
      format.rss { render :template => "rss/activities" }         
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end 
  end  

  private
  
    def check_for_user
    if params[:user_id]
      @user = User.find(params[:user_id])
    elsif logged_in?
      @user = current_user
    else
      access_denied and return
    end
  end
  
end
