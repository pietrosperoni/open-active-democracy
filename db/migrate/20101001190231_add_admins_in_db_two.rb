class AddAdminsInDbTwo < ActiveRecord::Migration
  def self.up
    add_index :admins, :national_identity
  end

  def self.down
  end
end
