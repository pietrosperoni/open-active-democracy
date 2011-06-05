class RenameGender < ActiveRecord::Migration
  def self.up
    remove_column :users, :gender
    add_column :users ,:my_gender, :string
  end

  def self.down
  end
end
