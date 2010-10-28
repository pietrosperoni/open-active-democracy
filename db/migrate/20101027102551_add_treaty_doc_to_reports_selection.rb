class AddTreatyDocToReportsSelection < ActiveRecord::Migration
  def self.up
    add_column :users, :reports_treaty_documents, :boolean, :default=>false
  end

  def self.down
  end
end
