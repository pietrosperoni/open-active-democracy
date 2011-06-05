class AddCategoryIdToCommentForSphinx < ActiveRecord::Migration
  def self.up
    add_column :comments, :category_id, :integer
  end

  def self.down
  end
end
