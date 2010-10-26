class TreatyDocumentsController < ApplicationController
  
  layout "esb_treaty_documents"
  
  def index
  end

  def show
    @active = "show"
    @chapter_name = TreatyDocument::TREATY_ARRAY.find {|c| c[:id]==params[:chapter_id].to_i}[:name]
    @stage_name = TreatyDocument::NEGOTIATION_STAGES.find {|c| c[:id]==params[:negotiation_status].to_i}[:name]
    @all_treaty_documents_for_chapter_and_status = TreatyDocument.find(:all, :conditions=>["chapter = ? AND negotiation_status = ?",params[:chapter_id], params[:negotiation_status]])
    render :layout=>false
  end
  
  def newest
    @active = "newest"
    @documents = TreatyDocument.find(:all, :limit=>20, :order=>"id DESC")
  end
  
  def show_chapter
    @active = "show_chapter"
    @chapter_id = params[:chapter_id]
    render :layout=>false
  end
  
end

