class AddTagsToTreatyDocs < ActiveRecord::Migration
  def self.up
    add_column :treaty_documents, :external_id, :integer
    add_column :treaty_documents, :cached_issue_list, :string

    add_index :treaty_documents, :external_id
    add_index :treaty_documents, :cached_issue_list
  end

  def self.down
  end
end
