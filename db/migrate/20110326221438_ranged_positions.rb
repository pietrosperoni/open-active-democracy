class RangedPositions < ActiveRecord::Migration
  def self.up
    add_column :priorities, :position_endorsed_24hr, :integer
    add_column :priorities, :position_endorsed_7days, :integer
    add_column :priorities, :position_endorsed_30days, :integer
  end

  def self.down
  end
end
