class AboutController < ApplicationController
  
  def index
    @page_title = tr("About {government_name}", "controller/about", :government_name => tr(current_government.name,"Name from database"))
  end
  
  def show
    if params[:id] == 'privacy'
      @page_title = tr("{government_name} Privacy Policy", "controller/about", :government_name => tr(current_government.name,"Name from database"))
      render :action => "privacy"
    elsif params[:id] == 'rules'
      @page_title = tr("{government_name} Rules", "controller/about", :government_name => tr(current_government.name,"Name from database"))
      render :action => "rules"
    elsif params[:id] == 'faq'
      @page_title = tr("Answers to Frequently Asked Questions at {government_name}", "controller/about", :government_name => tr(current_government.name,"Name from database"))
      render :action => "faq"
    elsif params[:id] == 'contributors'
      @page_title = tr("Contributors to {government_name}", "controller/about", :government_name => tr(current_government.name,"Name from database"))
      render :action => "contributors"
    elsif params[:id] == 'council' and Government.current.layout == "better_reykjavik"
      @page_title = tr("Reykjavik city council", "controller/council")
      render :action => 'council'
    else
      @page = Page.find_by_short_name(params[:id])
      @page_title = @page.name
    end
  end
  
end
