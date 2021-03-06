class WidgetsController < ApplicationController
  
  def index
    @page_title = tr("Widgets for your blog or website", "controller/widgets", :government_name => tr(current_government.name,"Name from database"))
    respond_to do |format|
      format.html
    end
  end
  
  def priorities
    @page_title = tr("Put priorities on your website", "controller/widgets", :government_name => tr(current_government.name,"Name from database"))
    if logged_in?
      @widget = Widget.new(:controller_name => "priorities", :user => current_user, :action_name => "top")
    else
      @widget = Widget.new(:controller_name => "priorities", :action_name => "top")
    end
    respond_to do |format|
      format.html
    end    
  end
  
  def discussions
    @page_title = tr("Put discussions on your website", "controller/widgets", :government_name => tr(current_government.name,"Name from database"))
    if logged_in?
      @widget = Widget.new(:controller_name => "news", :user => current_user, :action_name => "your_discussions")
    else
      @widget = Widget.new(:controller_name => "news", :action_name => "discussions")
    end
    respond_to do |format|
      format.html
    end    
  end
  
  def preview
    @widget = Widget.new(params[:widget])
    respond_to do |format|    
      format.js {
        render :update do |page|
          page.replace_html 'widget_preview', render(:partial => "widgets/preview")
        end
      }
    end
  end
  
  def preview_iframe
    render :layout => false
  end
  
end
