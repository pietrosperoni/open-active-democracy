class AddDescriptionToGovernments < ActiveRecord::Migration
  def self.up
    add_column :governments, :description, :text, :default=>""
  end

  def self.down
    remove_column :governments, :description
  end
end
