class TreatyDocumentsController < ApplicationController
  
  layout "esb_treaty_documents"
  
  def index
  end

  def show
    @active = "show"
    @tag = Tag.find_by_external_id(params[:chapter_id])
    @chapter_name = @tag.name
    @stage_name = TreatyDocument::NEGOTIATION_STAGES.find {|c| c[:id]==params[:negotiation_status].to_i}[:name]
    @all_treaty_documents_for_chapter_and_status = TreatyDocument.tagged_with("'#{@tag.name}'",:match_all=>:true).by_negotiation_status(params[:negotiation_status].to_i)
    render :layout=>false
  end
  
  def newest
    @active = "newest"
    @documents = TreatyDocument.find(:all, :order=>"date DESC").paginate :page => params[:page]
  end
  
  def show_chapter
    @active = "show_chapter"
    @chapter_id = params[:chapter_id]
    @tag = Tag.find_by_external_id(@chapter_id)
    render :layout=>false
  end
  
end

