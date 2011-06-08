require 'iconv'

class SearchesController < ApplicationController  
  
  def index
    Rails.logger.info("Category Name #{params[:category_name]} CRC #{params[:category_name].to_crc32}") if params[:cached_issue_list]
    @page_title = tr("Search {government_name} priorities", "controller/searches", :government_name => tr(current_government.name,"Name from database"))
    if params[:q]
      if Government.current.layout == "better_reykjavik"
        @query = params[:q].parameterize_full
      else
        @query = params[:q]
      end
      @page_title = tr("Search for '{query}'", "controller/searches", :government_name => tr(current_government.name,"Name from database"), :query => @query)
      @facets = ThinkingSphinx.facets @query, :all_facets => true, :with => {:partner_id => Partner.current ? Partner.current.id : 0}, :star => true, :page => params[:page]
      if params[:category_name]
        @search_results = @facets.for(:category_name=>params[:category_name])
      elsif params[:class]
        @search_results = @facets.for(:class=>params[:class].to_s)
      else
        @search_results = ThinkingSphinx.search @query, :with => {:partner_id => Partner.current ? Partner.current.id : 0}, :star => true, :retry_stale => true, :page => params[:page]
      end
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @priorities.to_xml(:except => [:user_agent,:ip_address,:referrer]) }
      format.json { render :json => @priorities.to_json(:except => [:user_agent,:ip_address,:referrer]) }
    end
  end
end
