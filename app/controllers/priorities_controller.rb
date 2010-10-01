class PrioritiesController < ApplicationController

  before_filter :login_required, :only => [:yours_finished, :yours_ads, :yours_top, :yours_lowest, :consider, :flag_inappropriate, :comment, :edit, :update, 
                                           :tag, :tag_save, :opposed, :endorsed, :destroy, :new, :set_subfilter]
  before_filter :admin_required, :only => [:bury, :successful, :compromised, :intheworks, :failed]
  before_filter :load_priority, :only => [:show, :activities, :endorsers, :opposers, :opposer_points, :endorser_points, :neutral_points, :everyone_points, 
                                             :opposed_top_points, :endorsed_top_points, :top_points, :discussions, :everyone_points, :documents, :opposer_documents, 
                                             :endorser_documents, :neutral_documents, :everyone_documents]
  before_filter :check_for_user, :only => [:yours, :network, :yours_finished, :yours_created]

  def load_priority
    if params[:id]
      @priority = Priority.find(params[:id])
    end
  end

  # GET /priorities
  def index
    redirect_to "/umraedur"
  end
  
  def set_subfilter
    if params[:filter]=="-1"
      session[:priorities_subfilter]=nil
    else
      session[:priorities_subfilter]=params[:filter]
    end
    redirect_to :controller=>params[:controller_name]          
  end
  
  def set_tag_filter
    if params[:tag_name] and params[:tag_name]=="-1"
      session[:selected_tag_name]=nil
      redirect_to :controller=>params[:controller_name]    
    elsif params[:tag_name] 
      session[:selected_tag_name]=params[:tag_name]
      redirect_to :controller=>params[:controller_name]
    else
      redirect_to :controller=>params[:controller_name]
    end
  end
  
  # GET /priorities/yours
  def yours
    @page_title = t('priorities.yours.title', :government_name => current_government.name)
    @priorities = @user.endorsements.active.paginate :include => :priority, :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html 
      format.js { render :layout => false, :text => "document.write('" + js_help.escape_javascript(render_to_string(:layout => false, :template => 'priorities/list_widget_small')) + "');" }
      format.xml { render :xml => @priorities.to_xml(:include => [:priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @priorities.to_json(:include => [:priority], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end

  # GET /priorities/newest
  def newest
    @page_title = t('priorities.newest.title', :target => current_government.target)
    @rss_url = newest_priorities_url(:format => 'rss')
    if session[:priorities_subfilter] and session[:priorities_subfilter]=="mine" and current_user
      @priorities = Priority.published.newest.by_user_id(current_user.id).paginate :page => params[:page], :per_page => params[:per_page]
    elsif session[:priorities_subfilter] and session[:priorities_subfilter]=="my_chapters" and current_user
      @priorities =  Priority.published.newest.tagged_with(TagSubscription.find_all_by_user_id(current_user.id).collect {|sub| sub.tag.name},:on=>:issues).paginate :page => params[:page], :per_page => params[:per_page]
    elsif session[:selected_tag_name]
      @priorities = Priority.published.newest.by_tag_name(session[:selected_tag_name]).paginate :page => params[:page], :per_page => params[:per_page]
    else
      @priorities = Priority.published.newest.paginate :page => params[:page], :per_page => params[:per_page]
    end
    respond_to do |format|
      format.html
      format.rss { render :action => "list" }
      format.js { render :layout => false, :text => "document.write('" + js_help.escape_javascript(render_to_string(:layout => false, :template => 'priorities/list_widget_small')) + "');" }      
      format.xml { render :xml => @priorities.to_xml(:except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @priorities.to_json(:except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  # GET /priorities/1
  def show
    if @priority.status == 'deleted'
      flash[:notice] = t('priorities.deleted')
    end
    @page_title = @priority.name
    @activities = @priority.activities.active.for_all_users.by_recently_updated.paginate :include => :user, :page => params[:page]
    respond_to do |format|
      format.html { render :action => "show" }
      format.xml { render :xml => @priority.to_xml(:except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @priority.to_json(:except => NB_CONFIG['api_exclude_fields']) }
    end
  end
  
  def discussions
    @page_title = t('priorities.discussions.title', :priority_name => @priority.name) 
    @activities = @priority.activities.active.discussions.by_recently_updated.for_all_users.paginate :page => params[:page], :per_page => 10
    if @activities.empty? # pull all activities if there are no discussions
      @activities = @priority.activities.active.paginate :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "activities" }
      format.xml { render :xml => @activities.to_xml(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
  
  def comments
    @priority = Priority.find(params[:id])  
    @page_title = t('priorities.comments.title', :priority_name => @priority.name) 
    @comments = Comment.published.by_recently_created.find(:all, :conditions => ["activities.priority_id = ?",@priority.id], :include => :activity).paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html
      format.rss { render :template => "rss/comments" }
      format.xml { render :xml => @comments.to_xml(:except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @comments.to_json(:except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  # GET /priorities/1/activities
  def activities
    @page_title = t('priorities.activities.title', :priority_name => @priority.name) 
    @activities = @priority.activities.active.for_all_users.by_recently_created.paginate :include => :user, :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html
      format.rss { render :template => "rss/activities" }
      format.xml { render :xml => @activities.to_xml(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
    end
  end 
  
  # GET /priorities/new
  # GET /priorities/new.xml
  def new
    redirect_if_not_logged_in
    if not params[:q].blank? and not @priorities and current_government.is_searchable?
      @priority_results = Priority.find_by_solr "(" + params[:q] + ") AND is_published:true", :limit => 25
      @priorities = @priority_results.docs      
    end
    
    @priority = Priority.new unless @priority

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /priorities/1/edit
  def edit
    @priority = Priority.find(params[:id])
    @page_name = t('priorities.edit.title', :priority_name => @priority.name)
    respond_to do |format|
      format.html # new.html.erb
    end    
  end
  
  # POST /priorities
  # POST /priorities.xml
  def create
    @priority = Priority.new()
    @priority.name = params[:q] if params[:q]
    if not logged_in?
      flash[:notice] = t('priorities.new.need_account', :target => current_government.target)
      session[:query] = params[:priority][:name] if params[:priority]
      access_denied
      return
    end
    @priority = Priority.new
    @priority.name = params[:priority][:name].strip
    @priority.description = params[:priority][:description].strip
    @priority.user = current_user
    @priority.ip_address = request.remote_ip
    @priority.issue_list = params[:custom_tag]
    @saved = @priority.save

    if @saved
      @activity = ActivityBulletinNew.create(:priority_id=>@priority.id, :user_id=>current_user.id, :issue_list=>@priority.cached_issue_list)
      @comment = @activity.comments.new(:content=>params[:priority][:description].strip)
      @comment.user = current_user
      @comment.request = request
      @comment.cached_issue_list = @priority.cached_issue_list
      @comment_saved = @comment.save
    end

    respond_to do |format|
      if @saved and @comment_saved
        flash[:notice] = t('priorities.new.success', :priority_name => @priority.name)
        format.html { redirect_to(@priority) }    
      else
        flash[:notice] = "Gat ekki geymt.  Þú verður að setja inn umræðuefni og útskýringu"
        format.html { redirect_to :controller => "priorities", :action => "new", :notice=>flash[:notice] }
      end
    end
  end

  # PUT /priorities/1
  # PUT /priorities/1.xml
  def update
    @priority = Priority.find(params[:id])
    @previous_name = @priority.name
    @page_name = t('priorities.edit.title', :priority_name => @priority.name)
    respond_to do |format|
      if params[:commit]=="Vista hugmynd"
        if @priority.update_attributes(params[:priority]) and @previous_name != params[:priority][:name]
          # already renamed?
          @activity = ActivityPriorityRenamed.find_by_user_id_and_priority_id(current_user.id,@priority.id)
          if @activity
            @activity.update_attribute(:updated_at,Time.now)
          else
            @activity = ActivityPriorityRenamed.create(:user => current_user, :priority => @priority)
          end
          format.html { 
            flash[:notice] = t('priorities.edit.success', :priority_name => @priority.name)
            redirect_to(@priority)         
          }
          format.js {
            render :update do |page|
              page.select('#priority_' + @priority.id.to_s + '_edit_form').each {|item| item.remove}          
              page.select('#activity_and_comments_' + @activity.id.to_s).each {|item| item.remove}                      
              page.insert_html :top, 'activities', render(:partial => "activities/show", :locals => {:activity => @activity, :suffix => "_noself"})
              page.replace_html 'priority_' + @priority.id.to_s + '_name', render(:partial => "priorities/name", :locals => {:priority => @priority})
              page.visual_effect :highlight, 'priority_' + @priority.id.to_s + '_name'
            end
          }
        else
          format.html { render :action => "edit" }
          format.js {
            render :update do |page|
              page.select('#priority_' + @priority.id.to_s + '_edit_form').each {|item| item.remove}
              page.insert_html :top, 'activities', render(:partial => "priorities/new_inline", :locals => {:priority => @priority})
              page['priority_name'].focus
            end
          }
        end
      else
        RAILS_DEFAULT_LOGGER.info("CHANGE NAME ERROR!!! #{@priority.inspect}")
        redirect_to(@priority)
      end
    end
  end

  # PUT /priorities/1/create_short_url
  def create_short_url
    @priority = Priority.find(params[:id])
    @short_url = @priority.create_short_url
    if @short_url
      @priority.save_with_validation(false)
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace "priority_short_url", render(:partial => "priorities/short_url", :locals => {:priority => @priority})
          page << "short_url.select();"
        end
      }
    end
  end

  # PUT /priorities/1/flag_inappropriate
  def flag_inappropriate
    @priority = Priority.find(params[:id])
    @saved = ActivityPriorityFlag.create(:priority => @priority, :user => current_user)
    respond_to do |format|
      flash[:notice] = t('priorities.change.flagged', :priority_name => @priority.name, :admin_name => current_government.admin_name)
      format.html { redirect_to(@priority) }
    end
  end  
  
  # PUT /priorities/1/bury
  def bury
    @priority = Priority.find(params[:id])
    @priority.bury!
    ActivityPriorityBury.create(:priority => @priority, :user => current_user)
    respond_to do |format|
      flash[:notice] = t('priorities.buried', :priority_name => @priority.name)
      format.html { redirect_to(@priority) }
    end
  end  
  
  # PUT /priorities/1/successful
  def successful
    @priority = Priority.find(params[:id])
    @priority.successful!
    respond_to do |format|
      flash[:notice] = t('priorities.successful', :priority_name => @priority.name)
      format.html { redirect_to(@priority) }
    end
  end  
  
  # PUT /priorities/1/intheworks
  def intheworks
    @priority = Priority.find(params[:id])
    @priority.intheworks!
    respond_to do |format|
      flash[:notice] = t('priorities.intheworks', :priority_name => @priority.name)
      format.html { redirect_to(@priority) }
    end
  end  
  
  # PUT /priorities/1/failed
  def failed
    @priority = Priority.find(params[:id])
    @priority.failed!
    respond_to do |format|
      flash[:notice] = t('priorities.failed', :priority_name => @priority.name)
      format.html { redirect_to(@priority) }
    end
  end  
  
  # PUT /priorities/1/compromised
  def compromised
    @priority = Priority.find(params[:id])
    @priority.compromised!
    respond_to do |format|
      flash[:notice] = t('priorities.compromised', :priority_name => @priority.name)
      format.html { redirect_to(@priority) }
    end
  end  
  
  # GET /priorities/1/tag
  def tag
    @priority = Priority.find(params[:id])
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html 'priority_' + @priority.id.to_s + '_tags', render(:partial => "priorities/tag", :locals => {:priority => @priority})
          page['priority_' + @priority.id.to_s + "_issue_list"].focus          
        end        
      }
    end
  end

  # POST /priorities/1/tag
  def tag_save
    @priority = Priority.find(params[:id])
    @priority.update_attributes(params[:priority])    
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html 'priority_' + @priority.id.to_s + '_tags', render(:partial => "priorities/tag_show", :locals => {:priority => @priority}) 
        end        
      }
    end
  end
  
  # DELETE /priorities/1
  def destroy
    if current_user.is_admin?
      @priority = Priority.find(params[:id])
    else
      @priority = current_user.created_priorities.find(params[:id])
    end
    return unless @priority
    name = @priority.name
    @priority.send_later(:destroy)
    flash[:notice] = t('priorities.destroy.success', :priority_name => name)
    respond_to do |format|
      format.html { redirect_to yours_created_priorities_url }    
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
