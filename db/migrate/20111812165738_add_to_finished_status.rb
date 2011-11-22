class AddToFinishedStatus < ActiveRecord::Migration
  def self.up
    add_column :priority_status_change_logs, :subject, :string
    add_column :priority_status_change_logs, :date, :datetime
    add_column :priorities, :finished_status_subject, :string
    add_column :priorities, :finished_status_date, :datetime
  end

  def self.down
  end
end