class AddToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :last_sent_report, :datetime, :default=>nil
  end

  def self.down
  end
end
