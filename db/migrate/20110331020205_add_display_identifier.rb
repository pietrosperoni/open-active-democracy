class AddDisplayIdentifier < ActiveRecord::Migration
  def self.up
    add_column :users, :identifier_url, :string
    add_index :users, :identifier_url, :unique => true
  end

  def self.down
  end
end
