class AddFlagCounts < ActiveRecord::Migration
  def self.up
    add_column :priorities, :flags_count, :integer, :default => 0
    add_column :questions, :flags_count, :integer, :default => 0
    add_column :documents, :flags_count, :integer, :default => 0
  end

  def self.down
  end
end
