class AddTagTypeToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :tag_type, :integer
  end

  def self.down
  end
end
