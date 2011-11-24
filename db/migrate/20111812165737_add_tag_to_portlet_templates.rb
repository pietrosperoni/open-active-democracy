class AddTagToPortletTemplates < ActiveRecord::Migration
  def self.up
    add_column :portlet_templates, :tag, :string
  end

  def self.down
    remove_column :portlet_templates, :tag
  end
end