require 'acts-as-taggable-on'

ActiveRecord::Base.send :include, ActiveRecord::Acts::TaggableOn
ActiveRecord::Base.send :include, ActiveRecord::Acts::Tagger

Rails.logger.info "** acts_as_taggable_on: initialized properly."