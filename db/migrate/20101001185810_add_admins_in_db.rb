class AddAdminsInDb < ActiveRecord::Migration
  def self.up
    create_table "admins", :force => true do |t|
      t.integer "national_identity", :null => false
    end    
    
    Admin.create(:national_identity=>"1907724039")
    Admin.create(:national_identity=>"2707634999")
  end

  def self.down
  end
end
