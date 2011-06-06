class AddExstraUserInfo < ActiveRecord::Migration
  def self.up
    add_column :users, :gender, :string
    add_column :users, :age_group, :string
    add_column :users, :post_code, :string
  end

  def self.down
  end
end
