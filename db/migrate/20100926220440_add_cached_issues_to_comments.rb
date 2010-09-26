class AddCachedIssuesToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :cached_issue_list, :string
  end

  def self.down
  end
end
