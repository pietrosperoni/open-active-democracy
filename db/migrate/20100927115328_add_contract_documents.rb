class AddContractDocuments < ActiveRecord::Migration
  def self.up
    add_index :tags, :weight
    add_index :activities, :question_id
    add_index :tags, :tag_type
    add_index :questions, :cached_issue_list
    add_index :comments, :cached_issue_list

    add_column :activities, :cached_issue_list, :string
    add_index :activities, :cached_issue_list
    
    create_table "treaty_documents", :force => true do |t|
      t.integer "chapter",                   :null => false
      t.integer "document_content_type",     :null => false
      t.integer "negotiation_status",        :null => false
      t.integer "document_type",             :null => false
      t.string  "title",                     :null => false
      t.string  "url",                       :null => false
      t.timestamps
    end    
  end

  def self.down
  end
end
