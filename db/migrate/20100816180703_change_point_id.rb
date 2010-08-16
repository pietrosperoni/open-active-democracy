class ChangePointId < ActiveRecord::Migration
  def self.up
    remove_column :revisions, :point_id
    add_column :revisions, :question_id, :integer
  end

  def self.down
  end
end
