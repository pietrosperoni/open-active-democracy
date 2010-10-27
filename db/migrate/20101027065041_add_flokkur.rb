class AddFlokkur < ActiveRecord::Migration
  def self.up
    add_column :treaty_documents, :category, :string
    add_column :treaty_documents, :date, :datetime
    add_index :treaty_documents, :category
  end

  def self.down
  end
end
