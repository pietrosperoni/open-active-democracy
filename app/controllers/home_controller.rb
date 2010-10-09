class HomeController < ApplicationController
  
  layout "esb"
  
  def index
  end 
  
  def top_issues
    @issues = Tag.most_priorities.all(:include => :top_priority, :limit => 10)
  end  
  
  def rules
    @issues = Tag.most_priorities.all(:include => :top_priority, :limit => 10)
  end  
  
  def help
    @issues = Tag.most_priorities.all(:include => :top_priority, :limit => 10)
  end
  
   def contact
    @issues = Tag.most_priorities.all(:include => :top_priority, :limit => 10)
  end 
  
end
