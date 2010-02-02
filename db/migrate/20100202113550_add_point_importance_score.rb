class AddPointImportanceScore < ActiveRecord::Migration
  def self.up
	create_table :point_importance_scores do |t|
		t.column :user_id, :integer
		t.column :point_id, :integer
		t.column :importance_score, :integer
		t.timestamps
	end
  end

  def self.down
  end
end
