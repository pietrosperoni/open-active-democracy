# coding: utf-8

namespace :hverfapottar do

  desc "initialize hverfapottar"
  task :init => :environment do
    hverfi = {
      'Árbær'       => 'arbaer',
      'Breiðholt'   => 'breidholt',
      'Grafarvogur' => 'grafarvogur',
      'Hlíðar'      => 'hlidar',
      'Kjalarnes'   => 'kjalarnes',
      'Laugardalur' => 'laugardalur',
      'Miðborg'     => 'midborg',
      'Vesturbær'   => 'vesturbaer',
      'Háaleiti- og bústaðir' => 'haaleiti',
      'Grafarholt og Úlfarsárdalur' => 'grafarholt',
    }

    partner_tags = ["Maintenance projects", "New development projects"]

    Partner.transaction do
      partner_tags.each do |tag_name|
        Tag.find_or_create_by_name(tag_name)
        template_name = "priorities.#{tag_name.downcase.gsub(/\s/, '_')}"
        template = PortletTemplate.find_or_create_by_name(template_name)
        template.portlet_template_category_id = PortletTemplateCategory.find_by_name("priorities.name")
        template.tag = tag_name
        template.item_limit = 3
        template.partial_name = "priority_list"
        template.locals_data_function = "setup_priorities_tagged"
        template.save
      end

      hverfi.each do |name, short_name|
        next if Partner.find_by_name(name)
        Partner.create(
          name: name,
          short_name: "betri-hverfi-#{short_name}",
          required_tags: partner_tags.join(','),
        )
      end
    end
  end

  desc "add hverfapottar portlets"
  task :add_portlets => :environment do
    PortletTemplate.create(
        name: "priorities.new_development_projects",
        portlet_template_category_id: 1,
        locals_data_function: "setup_priorities_tagged",
        partial_name: "priority_list",
        tag: "New development projects",
        item_limit: 3
    )
    PortletTemplate.create(
        name: "priorities.maintenance_projects",
        portlet_template_category_id: 1,
        locals_data_function: "setup_priorities_tagged",
        partial_name: "priority_list",
        tag: "Maintenance projects",
        item_limit: 3
    )
  end
end
