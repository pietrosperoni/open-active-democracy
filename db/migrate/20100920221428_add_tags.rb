class AddTags < ActiveRecord::Migration
  def self.up
    add_column :questions, :cached_issue_list, :string
  end

  def self.down
  end
end
