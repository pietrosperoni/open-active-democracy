class AnsweredAt < ActiveRecord::Migration
  def self.up
    add_column :questions, :answered_at, :datetime
  end

  def self.down
  end
end
