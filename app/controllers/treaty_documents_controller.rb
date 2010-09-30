class TreatyDocumentsController < ApplicationController
  
  layout "esb_treaty_documents"
  
  def index
  end

  def show
    @all_treaty_documents_for_chapter_and_status = TreatyDocument.find(:all, :conditions=>["chapter = ? AND negotiation_status = ?",params[:chapter_id], params[:negotiation_status]])
    render :layout=>false
  end
end

