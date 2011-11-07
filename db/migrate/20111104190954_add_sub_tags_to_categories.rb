class AddSubTagsToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :sub_tags, :string
  end

  def self.down
  end
end
