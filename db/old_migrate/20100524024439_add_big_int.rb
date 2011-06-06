class AddBigInt < ActiveRecord::Migration
  def self.up
    change_column :users, :facebook_uid, :bigint
  end

  def self.down
  end
end
