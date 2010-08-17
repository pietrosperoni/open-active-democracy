class QuestionsController < ApplicationController
 
  before_filter :login_required, :only => [:new, :create, :quality, :unquality, :your_priorities, :index, :destroy, :update_importance]
  before_filter :admin_required, :only => [:edit, :update]
 
  def index
    @page_title = t('points.yours.title', :government_name => current_government.name)
    @questions = Question.published.by_recently_created.paginate :conditions => ["user_id = ?", current_user.id], :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html { render :action => "index" }
      format.xml { render :xml => @questions.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @questions.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end
  
  def newest
    @page_title = t('points.newest.title', :government_name => current_government.name)
    @questions = Question.published.by_recently_created.paginate :page => params[:page], :per_page => params[:per_page]
    @rss_url = url_for :only_path => false, :format => "rss"
    respond_to do |format|
      format.html { render :action => "index" }
      format.rss { render :template => "rss/points" }
      format.xml { render :xml => @questions.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @questions.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
  
  def for_and_against
  	@page_title = t('points.for_and_against.title', :government_name => current_government.name)
    @priority=Priority.find(params[:id])
  	@questions_new_up = @priority.points.published.by_recently_created.up_value.five
  	@questions_new_down = @priority.points.published.by_recently_created.down_value.five
  	@questions_top_up = @priority.points.published.by_helpfulness.up_value.five
  	@questions_top_down = @priority.points.published.by_helpfulness.down_value.five
  	# @rss_url = url_for :only_path => false, :format => "rss"
  	respond_to do |format|
  		format.html { render :action => "for_and_against" }
  		#format.rss { render :template => "rss/points" }
  		#format.xml { render :xml => @questions.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
  		#format.json { render :json => @questions.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
  		format.js do
  			render :update do |page|
  				page.replace_html 'pro_top', :partial => "brbox", :locals => {:id => "pro_top", :questions => @questions_top_up}
  				page.replace_html 'con_top', :partial => "brbox", :locals => {:id => "con_top", :questions => @questions_top_down}
  				page.replace_html 'pro_new', :partial => "brbox", :locals => {:id => "pro_new", :questions => @questions_new_up}
  				page.replace_html 'con_new', :partial => "brbox", :locals => {:id => "con_new", :questions => @questions_new_down}
  			end
  		end
  	end
  end  	

  def all_points
  	if params[:foragainst] == "yes"
  		@questions_new = Question.published.up.by_recently_created :include => :priority
  		@questions_top = Question.published.up.top :include => :priority
  		@yesno = "J&aacute;"
  	elsif params[:foragainst] == "no"
  		@questions_new = Question.published.down.by_recently_created :include => :priority
  		@questions_top = Question.published.down.top :include => :priority	
  		@yesno = "Nei"
  	end
  	
  	@page_title = t('points.for_and_against.title', :government_name => current_government.name)
  	respond_to do |format|
  		format.html { render :action => "all_points" }
  	end
  end
  
  def your_priorities
    @page_title = t('points.your_priorities.title', :government_name => current_government.name)
    if current_user.endorsements_count > 0    
      if current_user.up_endorsements_count > 0 and current_user.down_endorsements_count > 0
        @questions = Question.published.by_recently_created.paginate :conditions => ["(points.priority_id in (?) and points.endorser_helpful_count > 0) or (points.priority_id in (?) and points.opposer_helpful_count > 0)",current_user.endorsements.active_and_inactive.endorsing.collect{|e|e.priority_id}.uniq.compact,current_user.endorsements.active_and_inactive.opposing.collect{|e|e.priority_id}.uniq.compact], :include => :priority, :page => params[:page], :per_page => params[:per_page]
      elsif current_user.up_endorsements_count > 0
        @questions = Question.published.by_recently_created.paginate :conditions => ["points.priority_id in (?) and points.endorser_helpful_count > 0",current_user.endorsements.active_and_inactive.endorsing.collect{|e|e.priority_id}.uniq.compact], :include => :priority, :page => params[:page], :per_page => params[:per_page]
      elsif current_user.down_endorsements_count > 0
        @questions = Question.published.by_recently_created.paginate :conditions => ["points.priority_id in (?) and points.opposer_helpful_count > 0",current_user.endorsements.active_and_inactive.opposing.collect{|e|e.priority_id}.uniq.compact], :include => :priority, :page => params[:page], :per_page => params[:per_page]
      end
      get_qualities      
    else
      @questions = nil
    end
    respond_to do |format|
      format.html { render :action => "index" }
      format.xml { render :xml => @questions.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @questions.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end 
 
  def revised
    @page_title = t('points.revised.title', :government_name => current_government.name)
    @revisions = Revision.published.by_recently_created.find(:all, :include => :point, :conditions => "points.revisions_count > 1").paginate :page => params[:page], :per_page => params[:per_page]
    @qualities = nil
    if logged_in? and @revisions.any? # pull all their qualities on the points shown
      @qualities = QuestionQuality.find(:all, :conditions => ["question_id in (?) and user_id = ? ", @revisions.collect {|c| c.question_id},current_user.id])
    end    
    respond_to do |format|
      format.html
      format.xml { render :xml => @revisions.to_xml(:include => [:point, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @revisions.to_json(:include => [:point, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
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
    @saved = @question.save
    respond_to do |format|
      if @saved
        if Revision.create_from_question(@question.id,request)
          session[:goal] = 'point'
          flash[:notice] = t('points.new.success')
          if facebook_session
            flash[:user_action_to_publish] = UserPublisher.create_question(facebook_session, @question)
          end          
          format.html { redirect_to("/questions/") }
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
  
  # POST /questions/1/quality
  def quality
    @question = Question.find(params[:id])
    @quality = @question.point_qualities.find_or_create_by_user_id_and_value(current_user.id,params[:value])
    @question.reload    
    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:region] == "point_detail"
            page.replace_html 'point_' + @question.id.to_s + '_helpful_button', render(:partial => "questions/button", :locals => {:point => @question, :quality => @quality })
            page.replace_html 'point_' + @question.id.to_s + '_helpful_chart', render(:partial => "documents/helpful_chart", :locals => {:document => @question })            
          elsif params[:region] = "point_inline"
#            page.select("point_" + @question.id.to_s + "_quality").each { |item| item.replace_html(render(:partial => "questions/button_small", :locals => {:point => @question, :quality => @quality, :priority => @question.priority}) ) }                       
            page.replace_html 'point_' + @question.id.to_s + '_quality', render(:partial => "questions/button_small", :locals => {:point => @question, :quality => @quality, :priority => @question.priority}) 
          end
        end        
      }
    end
  end  
  
  # POST /questions/1/unquality
  def unquality
    @question = Question.find(params[:id])
    @qualities = @question.point_qualities.find(:all, :conditions => ["user_id = ?",current_user.id])
    for quality in @qualities
      quality.destroy
    end
    @question.reload
    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:region] == "point_detail"
            page.replace_html 'point_' + @question.id.to_s + '_helpful_button', render(:partial => "questions/button", :locals => {:point => @question, :quality => @quality })
            page.replace_html 'point_' + @question.id.to_s + '_helpful_chart', render(:partial => "documents/helpful_chart", :locals => {:document => @question })            
          elsif params[:region] = "point_inline"
#            page.select("point_" + @question.id.to_s + "_quality").each { |item| item.replace_html(render(:partial => "questions/button_small", :locals => {:point => @question, :quality => @quality, :priority => @question.priority}) ) }
            page.replace_html 'point_' + @question.id.to_s + '_quality', render(:partial => "questions/button_small", :locals => {:point => @question, :quality => @quality, :priority => @question.priority}) 
          end          
        end       
      }
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
    ActivityQuestionDeleted.create(:user => current_user, :point => @question)
    respond_to do |format|
      format.html { redirect_to(questions_url) }
    end
  end
  
  private    
end
