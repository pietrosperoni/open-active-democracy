class AddDefaultLocaleToPartner < ActiveRecord::Migration
  def self.up
    add_column :partners, :default_locale, :string
  end

  def self.down
  end
end
