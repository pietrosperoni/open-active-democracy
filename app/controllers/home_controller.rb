class HomeController < ApplicationController

  caches_action :index,
                :if => proc {|c| c.do_action_cache? },
                :cache_path => proc {|c| c.action_cache_path},
                :expires_in => 5.minutes
  
  layout "home"
  
  def top_issues
    @issues = Tag.most_priorities.all(:include => :top_priority, :limit => 10)
  end  
  
  def index
    @page_title = tr("{government_name} Welcome","shared/language_selection_master",:government_name => tr(current_government.name,"Name from database"))
    @world_priorities = Priority.where(:partner_id=>Partner.find_by_short_name("world").id).published.top_rank.limit(3)
    @eu_eea_priorities = Priority.where(:partner_id=>Partner.find_by_short_name("eu").id).published.top_rank.limit(3)
    @country_partner = Partner.where(:iso_country_id=>@iso_country.id).first if @iso_country
    if @country_partner
      @country_partner_priorities = Priority.where(:partner_id=>@country_partner.id).published.top_rank.limit(3)
    else
      @country_partner_priorities = []
    end
    #@eu_eea_priorities = @country_partner_priorities = @world_priorities = Priority.published.find(:all, :limit=>3, :order=>"rand()")
    
    all_priorities = []
    all_priorities += @country_partner_priorities if @country_partner_priorities
    all_priorities += @world_priorities if @world_priorities
    all_priorities += @eu_eea_priorities if @eu_eea_priorities
    
    @endorsements = nil
    if logged_in? # pull all their endorsements on the priorities shown
      @endorsements = current_user.endorsements.active.find(:all, :conditions => ["priority_id in (?)", all_priorities.collect {|c| c.id}])
    end

  end
end
