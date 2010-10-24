class IssuesController < ApplicationController
  
  before_filter :get_tag_names, :except => :index
  before_filter :check_for_user, :only => [:yours, :yours_finished, :yours_created, :network]
      
  def index
    @page_title = current_government.tags_name.pluralize.titleize
    if request.format != 'html' or current_government.tags_page == 'list'
      @issues = Tag.most_priorities.paginate(:page => params[:page], :per_page => params[:per_page])
    end
    respond_to do |format|
      format.html {
        if current_government.tags_page == 'cloud'
          render :template => "issues/cloud"
        elsif current_government.tags_page == 'list'
          render :template => "issues/index"
        end
      }
      format.xml { render :xml => @issues.to_xml(:except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @issues.to_json(:except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  def show
    if not @tag
      flash[:error] = t('tags.show.gone', :tags_name => current_government.tags_name.downcase)
      redirect_to "/" and return 
    end
    @page_title = t('tags.show.title', :tag_name => @tag_names.titleize, :target => current_government.target)
    @priorities = Priority.tagged_with(@tag_names, :on => :issues).published.top_rank.paginate(:page => params[:page], :per_page => params[:per_page])
    get_endorsements    
    respond_to do |format|
      format.html { render :action => "list" }
      format.js { render :layout => false, :text => "document.write('" + js_help.escape_javascript(render_to_string(:layout => false, :template => 'priorities/list_widget_small')) + "');" }            
      format.xml { render :xml => @priorities.to_xml(:except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @priorities.to_json(:except => NB_CONFIG['api_exclude_fields']) }
    end    
  end

  alias :top :show

  def yours
    @page_title = t('tags.yours.title', :tag_name => @tag_names.titleize, :target => current_government.target)
    @priorities = @user.priorities.tagged_with(@tag_names, :on => :issues).paginate :page => params[:page], :per_page => params[:per_page]
    get_endorsements if logged_in?
    respond_to do |format|
      format.html { render :action => "list" }
      format.js { render :layout => false, :text => "document.write('" + js_help.escape_javascript(render_to_string(:layout => false, :template => 'priorities/list_widget_small')) + "');" }           
      format.xml { render :xml => @priorities.to_xml(:except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @priorities.to_json(:except => NB_CONFIG['api_exclude_fields']) }
    end   
  end

  private
  def get_tag_names
    @tag = Tag.find_by_slug(params[:slug])
    if not @tag
      flash[:error] = I18n.t('tags.show.gone', :tags_name => current_government.tags_name)
      redirect_to "/issues"
      return
    end
    @tag_names = @tag.name
  end  
  
  def get_endorsements
    @endorsements = nil
    if logged_in? # pull all their endorsements on the priorities shown
      @endorsements = Endorsement.find(:all, :conditions => ["priority_id in (?) and user_id = ? and status='active'", @priorities.collect {|c| c.id},current_user.id])
    end
  end
  
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
