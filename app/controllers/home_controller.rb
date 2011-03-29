class HomeController < ApplicationController
  
  layout "home"
  
  def top_issues
    @issues = Tag.most_priorities.all(:include => :top_priority, :limit => 10)
  end  
  
  def index
    @page_title = tr("Your Priorities Welcome","shared/language_selection_master")
    @world_priorities = Priority.where(:partner_id=>Partner.find_by_short_name("world").id).top_rank.limit(3)
    @country_partner = Partner.where(:iso_country_id=>@iso_country.id).first if @iso_country
    if @country_partner
      @country_partner_priorities = Priority.where(:partner_id=>country_partner.id).top_rank.limit(3)
    end
    
    all_priorities = []
    all_priorities += @country_partner_priorities if @country_partner_priorities
    all_priorities += @world_priorities if @world_priorities
    
    @endorsements = nil
    if logged_in? # pull all their endorsements on the priorities shown
      @endorsements = current_user.endorsements.active.find(:all, :conditions => ["priority_id in (?)", all_priorities.collect {|c| c.id}])
    end

  end
end
