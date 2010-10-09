class UnansweredQuestion < ActiveRecord::Migration
  def self.up
    add_column :activities, :unanswered_question, :boolean, :default=>false
    Activity.all.each do |a|
      if a.question_id
        a.unanswered_question = true
        a.save
      end
    end
  end

  def self.down
  end
end
