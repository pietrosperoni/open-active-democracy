class QuestionsController < ApplicationController
 
  before_filter :login_required, :only => [:new, :create, :quality, :unquality, :your_priorities, :index, :destroy, :update_importance]
  before_filter :admin_required, :only => [:edit, :update]
 
  def index
    @page_title = t('points.yours.title', :government_name => current_government.name)
    if session[:priorities_subfilter] and session[:priorities_subfilter]=="mine" and current_user
      @questions = Question.published.by_recently_created.by_user_id(current_user.id).paginate :page => params[:page], :per_page => params[:per_page]      
    elsif session[:priorities_subfilter] and session[:priorities_subfilter]=="my_chapters" and current_user
      @questions =  Question.published.by_recently_created.tagged_with(TagSubscription.find_all_by_user_id(current_user.id).collect {|sub| sub.tag.name},:on=>:issues).paginate :page => params[:page], :per_page => params[:per_page]
    elsif session[:selected_tag_name]
      @questions = Question.published.by_recently_created.by_tag_name(session[:selected_tag_name]).paginate :page => params[:page], :per_page => params[:per_page]
    else
      @questions = Question.published.by_recently_created.paginate :page => params[:page], :per_page => params[:per_page]
    end
    respond_to do |format|
      format.html { render :action => "index" }
      format.xml { render :xml => @questions.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @questions.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end
  
  def newest
    @page_title = t('points.newest.title', :government_name => current_government.name)
    if session[:priorities_subfilter] and session[:priorities_subfilter]=="mine" and current_user
      RAILS_DEFAULT_LOGGER.info("Selecting mine")
      @questions = Question.published.by_recently_created.by_user_id(current_user.id).paginate :page => params[:page], :per_page => params[:per_page]      
    elsif session[:priorities_subfilter] and session[:priorities_subfilter]=="my_chapters" and current_user
      RAILS_DEFAULT_LOGGER.info("Selecting my chapters")
      @questions =  Question.tagged_with(TagSubscription.find_all_by_user_id(current_user.id).collect {|sub| sub.tag.name},:on=>:issues).paginate :page => params[:page], :per_page => params[:per_page]
    elsif session[:selected_tag_name]
      RAILS_DEFAULT_LOGGER.info("Selecting tag name")
      @questions = Question.published.by_recently_created.by_tag_name(session[:selected_tag_name]).paginate :page => params[:page], :per_page => params[:per_page]
    else
      RAILS_DEFAULT_LOGGER.info("Selecting all")
      @questions = Question.published.by_recently_created.paginate :page => params[:page], :per_page => params[:per_page]
    end
    
    @rss_url = url_for :only_path => false, :format => "rss"
    respond_to do |format|
      format.html { render :action => "index" }
      format.rss { render :template => "rss/points" }
      format.xml { render :xml => @questions.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @questions.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
 
  # GET /questions/1
  def show
    @question = Question.find(params[:id])
    if @question.is_deleted?
      flash[:error] = t('points.deleted')
      redirect_to "/questions"
      return
    end    
    @page_title = @question.name
    @questions = nil
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @question.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @question.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end

  # GET /priorities/1/questions/new
  def new
    @action = new
    @question = Question.new
    @page_title = t('points.new.title')
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @question = Question.find(params[:id])
  end

  # POST /priorities/1/points
  def create
    @question = Question.new(params[:question])
    @question.user = current_user
    @question.issue_list = params[:custom_tag]
    @saved = @question.save
    @activity = ActivityBulletinNew.create(:question_id=>@question.id, :user_id=>current_user.id, :issue_list=>@question.cached_issue_list)
    respond_to do |format|
      if @saved
        if Revision.create_from_question(@question.id,request)
          session[:goal] = 'point'
          flash[:notice] = t('points.new.success')
          if facebook_session
            flash[:user_action_to_publish] = UserPublisher.create_question(facebook_session, @question)
          end          
          format.html { redirect_to(@question) }
        end
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /questions/1
  def update
    @question = Question.find(params[:id])
    respond_to do |format|
      if @question.update_attributes(params[:question])
        flash[:notice] = t('points.update.success', :question_name => @question.name)
        format.html { redirect_to(@question) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # GET /questions/1/activity
  def activity
    @question = Question.find(params[:id])
    @page_title = t('points.activity.title', :point_name => @question.name)
    @priority = @question.priority
    if logged_in? 
      @quality = @question.point_qualities.find_by_user_id(current_user.id) 
    else
      @quality = nil
    end
    @activities = @question.activities.active.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @activities.to_xml(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  

  # GET /questions/1/discussions
  def discussions
    @question = Question.find(params[:id])
    @page_title = t('points.discussions.title', :point_name => @question.name)
    @activities = @question.activities.active.discussions.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html { render :action => "activity" }
      format.xml { render :xml => @activities.to_xml(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
  # GET /questions/1/unhide
  def unhide
    @question = Question.find(params[:id])
    @priority = @question.priority
    @quality = nil
    if logged_in?
      @quality = @question.point_qualities.find_by_user_id(current_user.id)
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace 'point_' + @question.id.to_s, render(:partial => "questions/show", :locals => {:point => @question, :quality => @quality})
        end
      }
    end
  end

  # DELETE /questions/1
  def destroy
    @question = Question.find(params[:id])
    if @question.user_id != current_user.id and not current_user.is_admin?
      flash[:error] = t('point.destroy.access_denied')
      redirect_to(@question)
      return
    end
    @question.delete!
    # Commented out 230910 aom, because of an error point not defined ???
    # ActivityQuestionDeleted.create(:user => current_user, :point => @question)
    respond_to do |format|
      format.html { redirect_to(questions_url) }   
    end
  end
  
  private    
end
