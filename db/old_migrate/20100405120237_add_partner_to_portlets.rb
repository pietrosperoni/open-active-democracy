class AddPartnerToPortlets < ActiveRecord::Migration
  def self.up
    add_column :portlet_template_categories, :partner_id, :integer
  end

  def self.down
  end
end
