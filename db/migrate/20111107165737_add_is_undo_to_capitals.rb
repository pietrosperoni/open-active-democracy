class AddIsUndoToCapitals < ActiveRecord::Migration
  def self.up
    add_column :capitals, :is_undo, :boolean, :default=>false
  end

  def self.down
    remove_column :capitals, :is_undo
  end
end