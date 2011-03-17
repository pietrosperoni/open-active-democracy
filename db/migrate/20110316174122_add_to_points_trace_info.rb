class AddToPointsTraceInfo < ActiveRecord::Migration
  def self.up
    add_column :points, :user_agent, :string, :limit => 200
    add_column :points, :ip_address, :string
  end

  def self.down
  end
end
