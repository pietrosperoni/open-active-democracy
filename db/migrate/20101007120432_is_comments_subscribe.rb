class IsCommentsSubscribe < ActiveRecord::Migration
  def self.up
    add_column :users, :is_comments_subscribed, :boolean, :default=>true
  end

  def self.down
  end
end
