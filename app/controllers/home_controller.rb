class HomeController < ApplicationController
  layout "esb_no_chapters"

  def index
  end 
  
  def top_issues
    @issues = Tag.most_priorities.all(:include => :top_priority, :limit => 10)
  end  
  
  def rules
  end  
  
  def help
  end
  
  def contact
  end 
  
end
