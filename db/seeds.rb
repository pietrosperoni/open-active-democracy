# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# Create Categories

Category.create(:name=>"Framkvæmdir")
Category.create(:name=>"Skipulagsmál")
Category.create(:name=>"Samgöngur")
Category.create(:name=>"Velferðarmál")
Category.create(:name=>"Ferðamál")
Category.create(:name=>"Umhverfismál")
Category.create(:name=>"Menntamál")
Category.create(:name=>"Frístundir og útivist")
Category.create(:name=>"Íþróttir")
Category.create(:name=>"Menning og listir")
Category.create(:name=>"Mannréttindi")
Category.create(:name=>"Stjórnsýsla")
Category.create(:name=>"Alls konar")

if true
  Category.create(:name=>"Welfare")
  Category.create(:name=>"Law")
  Category.create(:name=>"Arts")
  Category.create(:name=>"Sports")
  Category.create(:name=>"Environment")
  Category.create(:name=>"Police")
  Category.create(:name=>"Public services")
  Category.create(:name=>"Military")
  Category.create(:name=>"Economy")
  Category.create(:name=>"Constitution")
  Category.create(:name=>"Banks")
  Category.create(:name=>"Entertainment")
  Category.create(:name=>"Immigration")
  Category.create(:name=>"Other")
else
  unless partner = Partner.find_by_short_name("dev")
    partner = Partner.create(:name=>"development", :short_name=>"dev")
  end
  Category.create(:name=>"User interface", :partner_id=>partner.id)
  Category.create(:name=>"General", :partner_id=>partner.id)
  Category.create(:name=>"Localization", :partner_id=>partner.id)
  Category.create(:name=>"Data sources", :partner_id=>partner.id)
end

p=Partner.new
p.name = "The European Union and EEA"
p.short_name = "eu"
p.geoblocking_enabled = true
p.geoblocking_open_countries = Tr8n::IsoCountry::EU_AND_EEA_COUNTRIES.join(",")
p.save

p=Partner.new
p.name = "Development"
p.short_name = "dev"
p.save

p=Partner.new
p.name = "The World"
p.short_name = "world"
p.save

# Create Portlet Templates
pc=PortletTemplateCategory.new
pc.name="Priorities"
pc.weight = 1
pc.save

pc2=PortletTemplateCategory.new
pc2.name="Categories"
pc2.weight = 2
pc2.save

pc3=PortletTemplateCategory.new
pc3.name="Network"
pc3.weight = 3
pc3.save

pc4=PortletTemplateCategory.new
pc4.name="News"
pc4.weight = 4
pc4.save

pc5=PortletTemplateCategory.new
pc5.name="Processes"
pc5.weight = 4
pc5.save

p=PortletTemplate.new
p.name="Latest Priorities"
p.portlet_template_category_id=pc.id
p.locals_data_function="setup_priorities_newest"
p.partial_name = "priority_newest"
p.item_limit = 3
p.weight = 1
p.save

p=PortletTemplate.new
p.name="Top Priorities"
p.portlet_template_category_id=pc.id
p.locals_data_function="setup_priorities_top"
p.partial_name = "priority_list"
p.item_limit = 3
p.weight = 2
p.save

p=PortletTemplate.new
p.name="Rising Priorities"
p.portlet_template_category_id=pc.id
p.locals_data_function="setup_priorities_rising"
p.partial_name = "priority_list"
p.item_limit = 3
p.weight = 3
p.save

p=PortletTemplate.new
p.name="Falling Priorities"
p.portlet_template_category_id=pc.id
p.locals_data_function="setup_priorities_falling"
p.partial_name = "priority_list"
p.item_limit = 3
p.weight = 4
p.save

p=PortletTemplate.new
p.name="Controversial Priorities"
p.portlet_template_category_id=pc.id
p.locals_data_function="setup_priorities_controversial"
p.partial_name = "priority_list"
p.item_limit = 3
p.weight = 5
p.save

p=PortletTemplate.new
p.name="Finished Priorities"
p.portlet_template_category_id=pc.id
p.locals_data_function="setup_priorities_finished"
p.partial_name = "priority_list"
p.item_limit = 3
p.weight = 6
p.save

p=PortletTemplate.new
p.name="Random Priorities"
p.portlet_template_category_id=pc.id
p.locals_data_function="setup_priorities_random"
p.partial_name = "priority_list"
p.item_limit = 5
p.weight = 7
p.caching_disabled = true
p.save

p=PortletTemplate.new
p.name="Category Cloud"
p.portlet_template_category_id=pc2.id
p.locals_data_function=nil
p.partial_name = "issues_cloud"
p.item_limit = nil
p.weight = 1
p.save

p=PortletTemplate.new
p.name="Category List"
p.portlet_template_category_id=pc2.id
p.locals_data_function=nil
p.partial_name = "issues_list"
p.item_limit = 3
p.weight = 2
p.save

p=PortletTemplate.new
p.name="Most Active Users"
p.portlet_template_category_id=pc3.id
p.locals_data_function=nil
p.partial_name = "network_list"
p.item_limit = 5
p.weight = 1
p.save

p=PortletTemplate.new
p.name="Newest Users"
p.portlet_template_category_id=pc3.id
p.locals_data_function=nil
p.partial_name = "network_newest"
p.item_limit = 5
p.weight = 2
p.save

p=PortletTemplate.new
p.name="Ambassadors"
p.portlet_template_category_id=pc3.id
p.locals_data_function=nil
p.partial_name = "network_ambassadors"
p.item_limit = 5
p.weight = 3
p.save

p=PortletTemplate.new
p.name="Discussions"
p.portlet_template_category_id=pc4.id
p.locals_data_function=nil
p.partial_name = "news_discussions"
p.item_limit = 3
p.weight = 1
p.save

p=PortletTemplate.new
p.name="Points"
p.portlet_template_category_id=pc4.id
p.locals_data_function=nil
p.partial_name = "news_points"
p.item_limit = 7
p.weight = 2
p.save

p=PortletTemplate.new
p.name="Activities"
p.portlet_template_category_id=pc4.id
p.locals_data_function=nil
p.partial_name = "news_activities"
p.item_limit = 7
p.weight = 3
p.save

p=PortletTemplate.new
p.name="News political capital"
p.portlet_template_category_id=pc4.id
p.locals_data_function=nil
p.partial_name = "news_capital"
p.item_limit = 7
p.weight = 4
p.save

p=PortletTemplate.new
p.name="Changes"
p.portlet_template_category_id=pc4.id
p.locals_data_function=nil
p.partial_name = "news_changes"
p.item_limit = 7
p.weight = 5
p.save    

p=PortletTemplate.new
p.name="Latest Video Discussions"
p.portlet_template_category_id=pc5.id
p.locals_data_function=nil
p.partial_name = "process_latest_video_discussions"
p.item_limit = 20
p.weight = 1
p.save    

p=PortletTemplate.new
p.name="Most Popular Videos"
p.portlet_template_category_id=pc5.id
p.locals_data_function=nil
p.partial_name = "process_most_popular_videos"
p.item_limit = 10
p.weight = 2
p.save    

p=PortletTemplate.new
p.name="Latest Processes"
p.portlet_template_category_id=pc5.id
p.locals_data_function = "setup_priorities_latest_processes"
p.partial_name = "priority_list"
p.item_limit = 3
p.weight = 3
p.save    

p=PortletTemplate.new
p.name="Latest Process Documents"
p.portlet_template_category_id=pc5.id
p.locals_data_function=nil
p.partial_name = "process_latest_documents"
p.item_limit = 5
p.weight = 4
p.save

p=PortletTemplate.new
p.name="Icesave"
p.portlet_template_category_id=pc5.id
p.locals_data_function="setup_priorities_process_icesave"
p.partial_name = "priority_list"
p.item_limit = 3
p.weight = 5
p.save    
