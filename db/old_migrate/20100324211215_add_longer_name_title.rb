class AddLongerNameTitle < ActiveRecord::Migration
  def self.up
    change_column :priorities, :name, :string, :limit => 250 
  end

  def self.down
  end
end
