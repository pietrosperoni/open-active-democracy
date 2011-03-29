class HomeController < ApplicationController
  
  layout "home"
  
  def top_issues
    @issues = Tag.most_priorities.all(:include => :top_priority, :limit => 10)
  end  
  
  def index
    @page_title = "Your Priorities Home"
  end
end
