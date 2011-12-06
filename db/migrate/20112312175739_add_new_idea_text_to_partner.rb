class AddNewIdeaTextToPartner < ActiveRecord::Migration
  def self.up
    add_column :partners, :message_for_new_priority, :text
  end

  def self.down
  end
end
