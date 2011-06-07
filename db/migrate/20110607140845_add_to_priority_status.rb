class AddToPriorityStatus < ActiveRecord::Migration
  def self.up
    add_column :priorities, :finished_status_message, :text
  end

  def self.down
  end
end
