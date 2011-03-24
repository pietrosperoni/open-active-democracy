class AddRequestToPriority < ActiveRecord::Migration
  def self.up
    add_column :priorities, :user_agent, :string, :limit => 200
  end

  def self.down
  end
end
