class Ranking < ActiveRecord::Base
  acts_as_set_partner :table_name=>"rankings"

  belongs_to :priority
    
end
