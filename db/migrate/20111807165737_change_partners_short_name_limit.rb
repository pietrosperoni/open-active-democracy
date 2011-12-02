class ChangePartnersShortNameLimit < ActiveRecord::Migration
  def self.up
    change_column :partners, :short_name, :string, :limit => 50
  end

  def self.down
    change_column :partners, :short_name, :string, :limit => 20
  end
end