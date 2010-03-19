module ActiveRecord
  module Acts
    module SetPartner
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_set_partner(options = {})
          before_create :set_partner
      
          named_scope :filtered, lambda {{ :conditions=>"#{options[:table_name]}.partner_id #{Partner.current ? "= #{Partner.current.id}" : "LIKE '%' OR #{options[:table_name]}.partner_id IS NULL"}" }}
          class_eval <<-EOV
            include SetPartner::InstanceMethods
          EOV
        end
      end
      
      module InstanceMethods
        def set_partner
          self.partner_id = Partner.current.id if Partner.current
        end
      end
    end
  end
end