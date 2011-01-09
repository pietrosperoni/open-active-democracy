class AddForMmr < ActiveRecord::Migration
  def self.up
    add_column :priorities, :html_description, :text
    add_column :priorities, :block_emails_from_voting, :string
    
    create_table :allocated_user_points do |t|
      t.integer :user_id, :null=>false
      t.integer :priority_id, :null=>false
      t.integer :allocated_points, :null=>false
      t.timestamps
    end
    
    add_index :allocated_user_points, :user_id
    add_index :allocated_user_points, :priority_id    
  end

  def self.down
  end
end
