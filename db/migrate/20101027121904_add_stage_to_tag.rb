class AddStageToTag < ActiveRecord::Migration
  def self.up
    add_column :tags, :external_stage, :integer, :default=>0
  end

  def self.down
  end
end
