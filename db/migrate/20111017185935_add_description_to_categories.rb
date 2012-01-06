class AddDescriptionToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :description, :text, :default=>""
    Category.reset_column_information
    Category.all.each do |category|
      category.description = ""
      category.save
    end
  end

  def self.down
    remove_column :categories, :description
  end
end
