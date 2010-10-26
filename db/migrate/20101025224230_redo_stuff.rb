class RedoStuff < ActiveRecord::Migration
  def self.up
    remove_index :treaty_documents, :external_id
    remove_column :treaty_documents, :external_id
    
    add_column :tags, :external_id, :integer
    add_index :tags, :external_id
  end

  def self.down
  end
end
