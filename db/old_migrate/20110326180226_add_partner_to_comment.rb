class AddPartnerToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :partner_id, :integer
  end

  def self.down
  end
end
