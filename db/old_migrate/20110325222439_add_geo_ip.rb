class AddGeoIp < ActiveRecord::Migration
  def self.up
    add_column :partners, :geoblocking_enabled, :boolean, :default=>false
    add_column :partners, :geoblocking_open_countries, :string, :default=>""
    add_column :users, :geoblocking_open_countries, :string, :default=>""
  end

  def self.down
  end
end
