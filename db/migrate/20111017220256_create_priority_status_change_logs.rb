class CreatePriorityStatusChangeLogs < ActiveRecord::Migration
  def self.up
    create_table :priority_status_change_logs do |t|
      t.integer :priority_id
      t.datetime :created_at
      t.text :content, null: false
    end
  end

  def self.down
    drop_table :priority_status_change_logs
  end
end
