class Tr8n::IsoCountry < ActiveRecord::Base
  set_table_name :tr8n_iso_countries
  has_and_belongs_to_many :languages, :class_name => 'Tr8n::Language', :foreign_key => "tr8n_iso_country_id", :association_foreign_key=>"tr8n_language_id", :join_table=>"tr8n_iso_countries_tr8n_languages"
end
