class AboutController < ApplicationController
  
  def index
    @page_title = tr("About {government_name}", "controller/about", :government_name => current_government.name)
  end
  
  def show
    if params[:id] == 'privacy'
      @page_title = tr("{government_name} Privacy Policy", "controller/about", :government_name => current_government.name)       
      render :action => "privacy"
    elsif params[:id] == 'rules'
      @page_title = tr("{government_name} Rules", "controller/about", :government_name => current_government.name)     
      render :action => "rules"
    elsif params[:id] == 'faq'
      @page_title = tr("Answers to Frequently Asked Questions at {government_name}", "controller/about", :government_name => current_government.name)      
      render :action => "faq"
    elsif params[:id] == 'stimulus'
      @page_title = "How America rates the stimulus package"
      render :action => "stimulus"      
    elsif params[:id] == 'congress'
      redirect_to "http://hellocongress.org/"
      return
    else
      @page = Page.find_by_short_name(params[:id])
      @page_title = @page.name
    end
  end
  
end
