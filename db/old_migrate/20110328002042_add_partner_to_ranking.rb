class AddPartnerToRanking < ActiveRecord::Migration
  def self.up
    add_column :rankings, :partner_id, :integer
  end

  def self.down
  end
end
