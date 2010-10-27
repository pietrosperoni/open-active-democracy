class QuestionsController < ApplicationController
 
  before_filter :login_required, :only => [:new, :create, :quality, :unquality, :your_priorities, :destroy, :update_importance, :flag]
  before_filter :admin_required, :only => [:edit, :update, :abusive, :not_abusive]
 # before_filter :set_default_subfilter
 
 def set_subfilter
    if params[:filter]=="-1"
      session[:questions_subfilter]="answered"
    else
      session[:questions_subfilter]=params[:filter]
    end
    redirect_to :action=>:index
  end
 
  def set_default_subfilter
    if session[:questions_subfilter]==nil
      session[:questions_subfilter]="answered"
    end
  end
 
  def index
    RAILS_DEFAULT_LOGGER.info(session[:questions_subfilter])
    @page_title = t('points.yours.title', :government_name => current_government.name)
    if session[:priorities_subfilter] and session[:priorities_subfilter]=="mine" and current_user
      @questions = Question.published.by_subfilter(session[:questions_subfilter]).by_recently_created.by_user_id(current_user.id).paginate :page => params[:page], :per_page => params[:per_page]      
    elsif session[:priorities_subfilter] and session[:priorities_subfilter]=="my_chapters" and current_user
      @questions =  Question.published.by_subfilter(session[:questions_subfilter]).by_recently_created.tagged_with(TagSubscription.find_all_by_user_id(current_user.id).collect {|sub| sub.tag.name},:on=>:issues).paginate :page => params[:page], :per_page => params[:per_page]
    elsif session[:selected_tag_name]
      @questions = Question.published.by_subfilter(session[:questions_subfilter]).by_recently_created.by_tag_name(session[:selected_tag_name]).paginate :page => params[:page], :per_page => params[:per_page]
    else
      @questions = Question.published.by_subfilter(session[:questions_subfilter]).by_recently_created.paginate :page => params[:page], :per_page => params[:per_page]
    end
    if request.format.js?
      @questions=process_display_array(@questions)
    else
      reset_displayed_array(@questions)
    end
    @rss_url = newest_questions_url(:format => 'rss')
    
    respond_to do |format|
      format.html { render :action => "index" }
      format.js {
        render :update do |page|
          unless false#@activities.empty?
          page.insert_html :top, "questions", render(:partial => "index" )
          page << "FB.XFBML.parse(document.getElementById('questions'));"
          end
        end
      }
      format.rss { render :action => "list" }
      format.xml { render :xml => @questions.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @questions.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end
  
  def newest
    RAILS_DEFAULT_LOGGER.info(session[:questions_subfilter])
    @page_title = t('points.yours.title', :government_name => current_government.name)
    if session[:priorities_subfilter] and session[:priorities_subfilter]=="mine" and current_user
      @questions = Question.published.by_subfilter(session[:questions_subfilter]).by_recently_created.by_user_id(current_user.id).paginate :page => params[:page], :per_page => params[:per_page]      
    elsif session[:priorities_subfilter] and session[:priorities_subfilter]=="my_chapters" and current_user
      @questions =  Question.published.by_subfilter(session[:questions_subfilter]).by_recently_created.tagged_with(TagSubscription.find_all_by_user_id(current_user.id).collect {|sub| sub.tag.name},:on=>:issues).paginate :page => params[:page], :per_page => params[:per_page]
    elsif session[:selected_tag_name]
      @questions = Question.published.by_subfilter(session[:questions_subfilter]).by_recently_created.by_tag_name(session[:selected_tag_name]).paginate :page => params[:page], :per_page => params[:per_page]
    else
      @questions = Question.published.by_subfilter(session[:questions_subfilter]).by_recently_created.paginate :page => params[:page], :per_page => params[:per_page]
    end
    if request.format.js?
      @questions=process_display_array(@questions)
    else
      reset_displayed_array(@questions)
    end
    @rss_url = newest_questions_url(:format => 'rss')
    
    respond_to do |format|
      format.html { render :action => "index" }
      format.js {
        render :update do |page|
          unless @questions.empty?
            page.insert_html :top, "questions_div", render(:partial => "index" )
            page << "FB.XFBML.parse(document.getElementById('questions_div'));"
          end
        end
      }
      format.rss { render :action => "list" }
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
    @action = "new"
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
    @activity = ActivityBulletinNew.create(:question_id=>@question.id, :user_id=>current_user.id, :issue_list=>@question.cached_issue_list,:unanswered_question=>true)
    respond_to do |format|
      if @saved
        if Revision.create_from_question(@question.id,request)
          UserMailer.deliver_new_question(@question)
          session[:goal] = 'point'
          flash[:notice] = t('esb.question.success')
          if current_facebook_user and params[:send_to_facebook]
            current_facebook_user.fetch
            UserPublisher.create_question(current_facebook_user, @question)
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
        if @question.answer!=nil
          @question.answered_at = Time.now
          @question.save
          Activity.find_all_by_question_id(@question.id).each do |a|
            a.unanswered_question=false
            a.save
          end
        end
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

  def flag
    @question = Question.find(params[:id])
    @question.flag_by_user(current_user)

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.js {
        render :update do |page|
          if current_user.is_admin?
            page.replace_html "flagged_question_info_#{@question.id}", render(:partial => "questions/flagged", :locals => {:question => @question})
          else
            page.replace_html "flagged_question_info_#{@question.id}", "<div class='warning_inline'>Takk fyrir að vekja athygli okkar á þessu umræðuefni.</div>"
          end
        end        
      }
    end    
  end  

  def abusive
    @question = Question.find(params[:id])
    @question.abusive!
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "flagged_question_info_#{@question.id}", "<div class='warning_inline'>Þessari spurningu hefur verið eytt og viðvörun send.</div>"
        end        
      }
    end    
  end

  def not_abusive
    @question = Question.find(params[:id])
    @question.update_attribute(:flags_count, 0)
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "flagged_question_info_#{@question.id}",""
        end        
      }
    end    
  end

  private    
end
