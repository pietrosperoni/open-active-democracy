class GovernmentsController < ApplicationController

  before_filter :admin_required
  
  def authorized?
    current_user.is_admin? and current_government.id == params[:id]
  end

  # GET /governments/1/edit
  def edit
    @government = Government.find(params[:id])
    @page_title = tr("{government_name} settings", "controller/governments", :government_name => tr(current_government.name,"Name from database"))
  end
  
  def apis
    @government = Government.find(params[:id])
    @page_title = tr("Third Party API settings", "controller/governments", :government_name => tr(current_government.name,"Name from database"))
  end

  # PUT /governments/1
  # PUT /governments/1.xml
  def update
    @government = Government.find(params[:id])
    @page_title = tr("{government_name} settings", "controller/governments", :government_name => tr(current_government.name,"Name from database"))
    respond_to do |format|
      if @government.update_attributes(params[:government])
        flash[:notice] = tr("Saved {government_name} settings", "controller/governments", :government_name => tr(current_government.name,"Name from database"))
        format.html { redirect_to edit_government_url(current_government) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

end
