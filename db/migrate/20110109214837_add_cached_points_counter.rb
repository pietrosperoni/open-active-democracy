class AddCachedPointsCounter < ActiveRecord::Migration
  def self.up
    add_column :priorities, :cached_allocated_points_counter, :integer, :default=>0
  end

  def self.down
  end
end
