class AddToFinishedStatus < ActiveRecord::Migration

  def self.up
    add_column :priority_status_change_logs, :subject, :string, null: false
    add_column :priority_status_change_logs, :date, :date
    change_column :priority_status_change_logs, :content, :text, null: true
    add_column :priorities, :finished_status_subject, :string
    add_column :priorities, :finished_status_date, :date
  end

  def self.down
  end
end
