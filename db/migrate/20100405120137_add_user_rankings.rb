class AddUserRankings < ActiveRecord::Migration
  def self.up
    create_table "user_rankings", :force => true do |t|
      t.integer  "user_id"
      t.integer  "version",        :default => 0
      t.integer  "position"
      t.integer  "capitals_count", :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "user_rankings", ["created_at"], :name => "rankings_created_at_index"
    add_index "user_rankings", ["user_id"], :name => "rankings_user_id"
    add_index "user_rankings", ["version"], :name => "rankings_version_index"
  end

  def self.down
  end
end
