class AddDescriptionToGovernments < ActiveRecord::Migration
  def self.up
    add_column :governments, :description, :text
  end

  def self.down
    remove_column :governments, :description
  end
end
