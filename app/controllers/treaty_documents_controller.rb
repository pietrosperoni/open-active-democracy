class TreatyDocumentsController < ApplicationController
  
  layout "esb_treaty_documents"
  
  before_filter :admin_required, :only => [:edit_stage]
  before_filter :login_required, :only => [:edit_stage]
  skip_before_filter :setup_welcome_cookie

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
  
  def edit_stage
    @chapter_id = params[:chapter_id]
    @tag = Tag.find_by_external_id(@chapter_id)
    if request.post?
      @tag.external_stage = params[:negotion_stage]
      @tag.save(false)
      redirect_to "/treaty_documents"
      return false
    end
    render :layout=>false    
  end
end

