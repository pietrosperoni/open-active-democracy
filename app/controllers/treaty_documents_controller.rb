class TreatyDocumentsController < ApplicationController
  
  layout "esb_treaty_documents"
  
  def TreatyDocumentsController
    
  end
  def index
     #@all_documents =  TreatyDocument.all.group_by(&:chapter) 
     respond_to do |format|
        format.html { render :action => "index" }
    end   
  end  
end

