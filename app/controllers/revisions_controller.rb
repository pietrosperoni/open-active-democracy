class RevisionsController < ApplicationController

  before_filter :get_point
  before_filter :login_required, :except => [:show, :clean]
  before_filter :admin_required, :only => [:destroy, :update, :edit]

  # GET /questions/1/revisions
  def index
    redirect_to @question
    return
  end

  # GET /questions/1/revisions/1
  def show
    if @question.is_deleted?
      flash[:error] = t('points.deleted')
      redirect_to @question.priority
      return
    end    
    @revision = @question.revisions.find(params[:id])
    @page_title = t('points.revision.show.title', :user_name => @revision.user.name.possessive, :point_name => @revision.name)
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /questions/1/revisions/1/clean
  def clean
    @revision = @question.revisions.find(params[:id])
    @page_title = t('points.revision.show.title', :user_name => @revision.user.name.possessive, :point_name => @revision.name)
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /questions/1/revisions/new
  def new
    @revision = @question.revisions.new
    @revision.name = @question.name
    @revision.content = @question.content
    @revision.website = @question.website
    @revision.value = @question.value
    @revision.other_priority = @question.other_priority
    @page_title = t('points.revision.new.title', :point_name => @question.name)    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /questions/1/revisions/1/edit
  def edit
    @revision = @question.revisions.find(params[:id])
  end

  # POST /questions/1/revisions
  def create
    @revision = @question.revisions.new(params[:revision])
    @revision.user = current_user
    respond_to do |format|
      if @revision.save
        @revision.publish!
        # this is all to add a comment with their note
        if params[:comment][:content] and params[:comment][:content].length > 0
          activities = Activity.find(:all, :conditions => ["user_id = ? and type like 'ActivityQuestionRevision%' and created_at > '#{Time.now-5.minutes}'",current_user.id], :order => "created_at desc")
          if activities.any?
            activity = activities[0]
            @comment = activity.comments.new(params[:comment])
            @comment.user = current_user
            @comment.request = request
            if activity.priority
              # if this is related to a priority, check to see if they endorse it
              e = activity.priority.endorsements.active_and_inactive.find_by_user_id(@comment.user.id)
              @comment.is_endorser = true if e and e.is_up?
              @comment.is_opposer = true if e and e.is_down?
            end
            @comment.save_with_validation(false)            
          end
        end
        flash[:notice] = t('points.revision.new.success', :point_name => @question.name)
        format.html { redirect_to(@question) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /questions/1/revisions/1
  def update
    @revision = @question.revisions.find(params[:id])
    respond_to do |format|
      if @revision.update_attributes(params[:revision])
        flash[:notice] = t('points.revision.new.success', :point_name => @question.name)
        format.html { redirect_to(@revision) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /questions/1/revisions/1
  def destroy
    @revision = @question.revisions.find(params[:id])
    flash[:notice] = t('points.revision.destroy', :point_name => @question.name)
    @revision.destroy

    respond_to do |format|
      format.html { redirect_to(revisions_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  def get_point
    @question = Question.find(params[:question_id])
    @priority = @question.priority
  end
  
end
