require 'fix_top_endorsements'
require 'priority_ranker'
require 'user_ranker'

namespace :schedule do
  desc "Fix top endorsements"
  task :fix_top_endorsements => :environment do
    o = FixTopEndorsements.new
    o.perform
  end

  desc "Priority Ranker"
  task :priority_ranker => :environment do
    o = PriorityRanker.new
    o.perform
  end

  desc "User Ranker"
  task :user_ranker => :environment do
    o = UserRanker.new
    o.perform
  end
end