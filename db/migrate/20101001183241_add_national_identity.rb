class AddNationalIdentity < ActiveRecord::Migration
  def self.up
    add_column :users, :national_identity, :string, :null=>false
    add_index :users, :national_identity, :unique=>true
  end

  def self.down
  end
end
