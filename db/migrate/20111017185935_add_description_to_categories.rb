class AddDescriptionToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :description, :text, :default=>""
    Category.transaction do |category|
      category.description = ""
      category.save
    end
  end

  def self.down
    remove_column :categories, :description
  end
end
