class SearchesController < ApplicationController
  
  layout "esb_search"
  
  def index
    @page_title = t('searches.index.title', :government_name => current_government.name)
    if params[:q]
      @query = params[:q]
      @page_title = t('searches.results', :government_name => current_government.name, :query => @query)
      @facets = ThinkingSphinx.facets params[:q], :all_facets => true, :page => params[:page]
      @search_results = ThinkingSphinx.search params[:q], :page => params[:page], :retry_stale => true
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @priorities.to_xml(:except => [:user_agent,:ip_address,:referrer]) }
      format.json { render :json => @priorities.to_json(:except => [:user_agent,:ip_address,:referrer]) }
    end
  end
  
end
