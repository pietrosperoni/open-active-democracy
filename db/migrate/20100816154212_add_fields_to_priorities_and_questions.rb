class AddFieldsToPrioritiesAndQuestions < ActiveRecord::Migration
  def self.up
    add_column :priorities, :description, :text
    add_column :questions, :answer, :text    

    add_column :tags, :weight, :integer, :default=>0
  end

  def self.down
  end
end
