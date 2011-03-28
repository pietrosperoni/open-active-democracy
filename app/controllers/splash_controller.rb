class SplashController < ApplicationController

  def index
    @page_title = tr("Watch what people are doing at {government_name}", "controller/splash", :government_name => tr(current_government.name,"Name from database"))
    if User.adapter == 'postgresql'
      @priorities = Priority.find :all, :conditions => "status='published' and position > 0 and endorsements_count > 2", :order => "RANDOM()", :limit => 200
    else
      @priorities = Priority.find :all, :conditions => "status='published' and position > 0 and endorsements_count > 2", :order => "rand()", :limit => 200
    end
  end  
  
end
