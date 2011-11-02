class AddHelpText < ActiveRecord::Migration
  def self.up
    add_column :governments, :message_for_ads, :text, :default=>""
    add_column :governments, :message_for_issues, :text, :default=>""
    add_column :governments, :message_for_network, :text, :default=>""
    add_column :governments, :message_for_finished, :text, :default=>""
    add_column :governments, :message_for_points, :text, :default=>""
    add_column :governments, :message_for_new_priority, :text, :default=>""
    add_column :governments, :message_for_news, :text, :default=>""
  end

  def self.down
  end
end
