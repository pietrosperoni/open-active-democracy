class AddChangeLogToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :priority_status_change_log_id, :integer
  end

  def self.down
    remove_column :activities, :priority_status_change_log_id
  end
end
