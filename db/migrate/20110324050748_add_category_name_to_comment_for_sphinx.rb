class AddCategoryNameToCommentForSphinx < ActiveRecord::Migration
  def self.up
    add_column :comments, :category_name, :string, :default=>"no cat"
  end

  def self.down
  end
end
