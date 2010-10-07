class HaveSentWelcome < ActiveRecord::Migration
  def self.up
    add_column :users, :have_sent_welcome, :boolean, :default=>false
  end

  def self.down
  end
end
