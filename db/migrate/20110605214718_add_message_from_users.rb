class AddMessageFromUsers < ActiveRecord::Migration
  def self.up
    add_column :governments, :message_to_users, :text, :default=>""
  end

  def self.down
  end
end
