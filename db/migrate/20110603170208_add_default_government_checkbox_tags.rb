class AddDefaultGovernmentCheckboxTags < ActiveRecord::Migration
  def self.up
    add_column :governments, :default_tags_checkbox, :string
  end

  def self.down
  end
end
