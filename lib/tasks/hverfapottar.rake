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

    Partner.transaction do
      hverfi.each do |name, short_name|
        next if Partner.find_by_name(name)
        Partner.create(name: name, short_name: "betri-hverfi-#{short_name}")
      end

      ["Maintenance projects", "New development projects"].each do |tag_name|
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
    end
  end
end