class AddPartnerIdToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :partner_id, :integer
  end

  def self.down
  end
end
