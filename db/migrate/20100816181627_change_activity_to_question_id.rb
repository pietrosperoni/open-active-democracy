class ChangeActivityToQuestionId < ActiveRecord::Migration
  def self.up
    remove_column :activities, :point_id
    add_column :activities, :question_id, :integer
  end

  def self.down
  end
end
