class CustomTagsForPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :default_tags, :string
    add_column :partners, :custom_tag_checkbox, :string
    add_column :partners, :custom_tag_dropdown_1, :string
    add_column :partners, :custom_tag_dropdown_2, :string
  end

  def self.down
  end
end
