class Tr8n::IsoCountry < ActiveRecord::Base
  set_table_name :tr8n_iso_countries
  has_and_belongs_to_many :tr8n_languages
end
