class AddNameVariations < ActiveRecord::Migration
  def self.up
    add_column :partners, :name_variations_data, :string, :limit => 350 
  end

  def self.down
  end
end
