class DocumentsController < ApplicationController
  
  before_filter :login_required, :only => [:new, :create, :quality, :unquality, :your_priorities, :destroy, :flag]
  before_filter :admin_required, :only => [:edit, :update, :abusive, :not_abusive]
 
  def index
    redirect_to :action=>"newest"
  end
  
  def newest
    @page_title = t('document.yours.title')
    if session[:priorities_subfilter] and session[:priorities_subfilter]=="mine" and current_user
      @documents = Document.published.by_recently_created.by_user_id(current_user.id).paginate :page => params[:page], :per_page => params[:per_page]      
    elsif session[:priorities_subfilter] and session[:priorities_subfilter]=="my_chapters" and current_user
      @documents =  Document.published.by_recently_created.tagged_with(TagSubscription.find_all_by_user_id(current_user.id).collect {|sub| sub.tag.name},:on=>:issues).paginate :page => params[:page], :per_page => params[:per_page]
    elsif session[:selected_tag_name]
      @documents = Document.published.by_recently_created.by_tag_name(session[:selected_tag_name]).paginate :page => params[:page], :per_page => params[:per_page]
    else
      @documents = Document.published.by_recently_created.paginate :page => params[:page], :per_page => params[:per_page]
    end
    RAILS_DEFAULT_LOGGER.info("Request format js #{request.format.js?}")
    if request.format.js?
      @documents=process_display_array(@documents)
    else
      reset_displayed_array(@documents)
    end
    @rss_url = newest_documents_url(:format => 'rss')

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          unless @documents.empty?
            page.insert_html :top, "documents_div", render(:partial => "newest" )
            page << "FB.XFBML.parse(document.getElementById('documents_div'));"
          end
        end
      }
      format.rss { render :action => "list" }
      format.xml { render :xml => @documents.to_xml(:except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @documents.to_json(:except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
 
 
  # GET /documents/1
  def show
    get_document
    if @document.is_deleted?
      flash[:error] = t('document.deleted')
      redirect_to "/" and return
    end
    @page_title = @document.name
    @documents = nil
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @document.to_xml(:include => :priority) }
      format.json { render :json => @document.to_json(:include => :priority) }
    end
  end
  
  # GET /documents/1/activity
  def activity
    get_document
    @page_title = t('document.activity.title', :document_name => @document.name)
    @priority = @document.priority
    if logged_in? 
      @quality = @document.qualities.find_by_user_id(current_user.id) 
    else
      @quality = nil
    end
    @activities = @document.activities.active.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @activities.to_xml(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  

  # GET /documents/1/discussions
  def discussions
    get_document
    @page_title =  t('document.discussions.title', :document_name => @document.name)
    @priority = @document.priority
    if logged_in? 
      @quality = @document.qualities.find_by_user_id(current_user.id) 
    else
      @quality = nil
    end
    @activities = @document.activities.active.discussions.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html { render :action => "activity" }
      format.xml { render :xml => @activities.to_xml(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
    end
  end

  # GET /priorities/1/documents/new
  def new
    @action = "new"
    @document = Document.new(params[:document])
    @page_title =  t('document.new.title')
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    get_document
    @page_title =  t('document.edit.title', :document_name => @document.name)
    @priority = @document.priority
  end

  # POST /priorities/1/documents
  def create
    @document = Document.new(params[:document])
    @document.user = current_user
    @document.issue_list = params[:custom_tag]
    @saved = @document.save
    respond_to do |format|
      if @saved
        if DocumentRevision.create_from_document(@document.id,request)
          session[:goal] = 'document'
          flash[:notice] = t('document.new.success', :document_name => @document.name)
          UserMailer.deliver_new_document(@document,true)
          UserMailer.deliver_new_document(@document,false)
          if current_facebook_user and params[:send_to_facebook]
            current_facebook_user.fetch
            UserPublisher.create_document(current_facebook_user, @document)
          end
          format.html { redirect_to(@document) }
        end
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /documents/1
  def update
    get_document
    @priority = @document.priority
    respond_to do |format|
      if @document.update_attributes(params[:document])
        flash[:notice] = t('document.new.save', :document_name => @document.name)
        format.html { redirect_to(@document) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # POST /documents/1/quality
  def quality
    get_document
    @quality = @document.qualities.find_or_create_by_user_id_and_value(current_user.id,params[:value].to_i)
    @document.reload    
    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:region] == "document_detail"
            page.replace_html 'document_' + @document.id.to_s + '_helpful_button', render(:partial => "documents/button", :locals => {:document => @document, :quality => @quality })
            page.replace_html 'document_' + @document.id.to_s + '_helpful_chart', render(:partial => "documents/helpful_chart", :locals => {:document => @document })            
          elsif params[:region] = "document_inline"
            page.replace_html 'document_' + @document.id.to_s + '_quality', render(:partial => "documents/button_small", :locals => {:document => @document, :quality => @quality, :priority => @document.priority}) 
          end
        end        
      }
    end
  end  
  
  # POST /documents/1/unquality
  def unquality
    get_document
    @qualities = @document.qualities.find(:all, :conditions => ["user_id = ?",current_user.id])
    for quality in @qualities
      quality.destroy
    end
    @document.reload
    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:region] == "document_detail"
            page.replace_html 'document_' + @document.id.to_s + '_helpful_button', render(:partial => "documents/button", :locals => {:document => @document, :quality => @quality })
            page.replace_html 'document_' + @document.id.to_s + '_helpful_chart', render(:partial => "documents/helpful_chart", :locals => {:document => @document })            
          elsif params[:region] = "document_inline"
            page.replace_html 'document_' + @document.id.to_s + '_quality', render(:partial => "documents/button_small", :locals => {:document => @document, :quality => @quality, :priority => @document.priority}) 
          end          
        end        
      }
    end
  end  
  
  # GET /documents/1/unhide
  def unhide
    get_document
    @priority = @document.priority
    @quality = nil
    if logged_in?
      @quality = @document.qualities.find_by_user_id(current_user.id)
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace 'document_' + @document.id.to_s, render(:partial => "documents/show", :locals => {:document => @document, :quality => @quality})
        end
      }
    end
  end

  # DELETE /documents/1
  def destroy
    get_document
    if @document.user_id != current_user.id and not current_user.is_admin?
      flash[:error] = t('document.destroy.error')
      redirect_to(@document)
      return
    end
    @document.delete!
    ActivityDocumentDeleted.create(:user => current_user, :document => @document)
    respond_to do |format|
      format.html { redirect_to(documents_url) }
    end
  end

  def flag
    @document = Document.find(params[:id])
    @document.flag_by_user(current_user)

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.js {
        render :update do |page|
          if current_user.is_admin?
            page.replace_html "flagged_document_info_#{@document.id}", render(:partial => "documents/flagged", :locals => {:document => @document})
          else
            page.replace_html "flagged_document_info_#{@document.id}", "<div class='warning_inline'>Takk fyrir að vekja athygli okkar á þessu umræðuefni.</div>"
          end
        end        
      }
    end    
  end  

  def abusive
    @document = Document.find(params[:id])
    @document.do_abusive
    @document.delete!
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "flagged_document_info_#{@document.id}", "<div class='warning_inline'>Þessu erindi hefur verið eytt og viðvörun send.</div>"
        end        
      }
    end    
  end

  def not_abusive
    @document = Document.find(params[:id])
    @document.update_attribute(:flags_count, 0)
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "flagged_document_info_#{@document.id}",""
        end        
      }
    end    
  end
  
  private    
    def get_document
      @document = Document.find(params[:id])
    end
end
