class ChartsController < ApplicationController

  def issues
    @page_title = tr("Most active {tags_name} at {government_name}", "controller/charts", :tags_name => current_government.tags_name.pluralize.downcase, :government_name => current_government.name)
    respond_to do |format|
      format.html
    end    
  end

  def gainers_24hr
    @page_title = tr("People with the fastest rising priorities in the last 24 hours", "controller/charts")
    @users = User.active.by_24hr_gainers.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html
      format.xml { render :xml => @users.to_xml(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @users.to_json(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def gainers_7days
    @page_title = tr("People with the fastest rising priorities this week", "controller/charts")
    @users = User.active.by_7days_gainers.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html
      format.xml { render :xml => @users.to_xml(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @users.to_json(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  def gainers_30days
    @page_title = tr("People with the fastest rising priorities this month", "controller/charts")
    @users = User.active.by_30days_gainers.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html
      format.xml { render :xml => @users.to_xml(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @users.to_json(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end    
  
  def losers_24hr
    @page_title = tr("People with the fastest falling priorities in the last 24 hours", "controller/charts")
    @users = User.active.by_24hr_losers.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html 
      format.xml { render :xml => @users.to_xml(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @users.to_json(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def losers_7days
    @page_title = tr("People with the fastest falling priorities this week", "controller/charts")
    @users = User.active.by_7days_losers.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html
      format.xml { render :xml => @users.to_xml(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @users.to_json(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end

  def losers_30days
    @page_title = tr("People with the fastest falling priorities this month", "controller/charts")
    @users = User.active.by_30days_losers.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format| 
      format.html 
      format.xml { render :xml => @users.to_xml(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @users.to_json(:include => [:top_endorsement, :referral, :partner_referral], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end


end
