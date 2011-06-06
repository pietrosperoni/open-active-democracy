class GoogleLoginSelection < ActiveRecord::Migration
  def self.up
    add_column :governments, :google_login_enabled, :boolean, :default=>false
  end

  def self.down
  end
end
