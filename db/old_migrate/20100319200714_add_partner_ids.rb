class AddPartnerIds < ActiveRecord::Migration
  def self.up
    add_column :priorities, :partner_id, :integer
    add_column :points, :partner_id, :integer
    add_column :portlet_containers, :partner_id, :integer
    add_column :tags, :partner_id, :integer     
  end

  def self.down
  end
end
