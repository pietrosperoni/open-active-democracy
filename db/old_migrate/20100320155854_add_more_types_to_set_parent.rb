class AddMoreTypesToSetParent < ActiveRecord::Migration
  def self.up
    add_column :ads, :partner_id, :integer
    add_column :documents, :partner_id, :integer
  end

  def self.down
  end
end
