class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end
    
    add_column :priorities, :category_id, :integer
    add_index :priorities, :category_id
  end

  def self.down
    drop_table :categories
  end
end
