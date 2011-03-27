class SearchesController < ApplicationController  
  
  def index
    Rails.logger.info("Category Name #{params[:category_name]} CRC #{params[:category_name].to_crc32}") if params[:cached_issue_list]
    @page_title = tr("Search {government_name} priorities", "controller/searches", :government_name => current_government.name)
    if params[:q]
      @query = params[:q]
      @page_title = tr("Search {government_name} priorites for '{query}'", "controller/searches", :government_name => current_government.name, :query => @query)
      @facets = ThinkingSphinx.facets params[:q], :all_facets => true, :with => {:partner_id => Partner.current ? Partner.current.id : 0}, :star => true, :page => params[:page]
      if params[:category_name]
        @search_results = @facets.for(:category_name=>params[:category_name])
      elsif params[:class]
        @search_results = @facets.for(:class=>params[:class].to_s)
      else
        @search_results = ThinkingSphinx.search params[:q], :with => {:partner_id => Partner.current ? Partner.current.id : 0}, :star => true, :retry_stale => true, :page => params[:page]
      end
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @priorities.to_xml(:except => [:user_agent,:ip_address,:referrer]) }
      format.json { render :json => @priorities.to_json(:except => [:user_agent,:ip_address,:referrer]) }
    end
  end
  end
