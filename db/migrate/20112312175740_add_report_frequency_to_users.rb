class AddReportFrequencyToUsers < ActiveRecord::Migration
  def self.up
    #Government.current = Government.all.last
    add_column :users, :report_frequency, :integer, default: 2
    User.reset_column_information
    User.transaction do
      User.all.each do |user|
        user.report_frequency = 0 if not user.is_newsletter_subscribed
        user.save
      end
    end
    remove_column :unsubscribes, :is_newsletter_subscribed
    remove_column :users, :is_newsletter_subscribed
  end

  def self.down
    #Government.current = Government.all.last
    add_column :unsubscribes, :is_newsletter_subscribed, :boolean, default: false
    add_column :users, :is_newsletter_subscribed, :boolean, default: true
    User.reset_column_information
    User.transaction do
      User.all.each do |user|
        user.is_newsletter_subscribed = false if user.report_frequency == 0
        user.save
      end
    end
    remove_column :users, :report_frequency
  end
end
