class AddRequiredTagsToPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :required_tags, :string
  end

  def self.down
    remove_column :partners, :required_tags
  end
end
