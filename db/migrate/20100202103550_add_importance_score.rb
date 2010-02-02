class AddImportanceScore < ActiveRecord::Migration
  def self.up
    add_column :points, :total_importance_score, :float
  end

  def self.down
  end
end
