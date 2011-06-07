class AddCountryIdToPartner < ActiveRecord::Migration
  def self.up
    add_column :partners, :iso_country_id, :integer
  end

  def self.down
  end
end
