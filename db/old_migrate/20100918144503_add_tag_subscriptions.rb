class AddTagSubscriptions < ActiveRecord::Migration
  def self.up
    create_table "tag_subscriptions", :id => false, :force => true do |t|
      t.integer "user_id",                   :null => false
      t.integer "tag_id",                    :null => false
    end
    
    add_index :tag_subscriptions, :user_id
    add_index :tag_subscriptions, :tag_id
    
    add_column :users, :reports_enabled, :boolean, :default=>false
    add_column :users, :reports_discussions, :boolean, :default=>false
    add_column :users, :reports_questions, :boolean, :default=>false
    add_column :users, :reports_documents, :boolean, :default=>false
    
    add_column :users, :reports_interval, :integer
  end

  def self.down
  end
end
