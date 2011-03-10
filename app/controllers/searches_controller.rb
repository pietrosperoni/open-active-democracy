class SearchesController < ApplicationController  
  
  def index
    Rails.logger.info("ISSUE LIST #{params[:cached_issue_list]} CRC #{params[:cached_issue_list].to_crc32}") if params[:cached_issue_list]
    @page_title = tr("Search {government_name} priorities", "controller/searches", :government_name => current_government.name)
    if params[:q]
      @query = params[:q]
      @page_title = tr("Search {government_name} priorites for '{query}'", "controller/searches", :government_name => current_government.name, :query => @query)
      @facets = ThinkingSphinx.facets params[:q], :all_facets => true, :page => params[:page]
      if params[:cached_issue_list]
        @search_results = @facets.for(:cached_issue_list=>params[:cached_issue_list])
      elsif params[:class]
        @search_results = @facets.for(:class=>params[:class].to_s)
      else
        @search_results = ThinkingSphinx.search params[:q], :page => params[:page], :retry_stale => true
      end
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @priorities.to_xml(:except => [:user_agent,:ip_address,:referrer]) }
      format.json { render :json => @priorities.to_json(:except => [:user_agent,:ip_address,:referrer]) }
    end
  end
  end
