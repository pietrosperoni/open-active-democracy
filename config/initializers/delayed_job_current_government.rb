Delayed::Worker.logger = Rails.logger

module Delayed
  class PerformableMethod

    def perform
      Government.current = Government.last
      Partner.current = object.instance_variable_get(:@current_partner_for_delayed)
      object.send(method_name, *args) if object
    rescue ActiveRecord::RecordNotFound
      # We cannot do anything about objects which were deleted in the meantime
      true
    end
    
  end
end

module Delayed
  module MessageSending
    def delay(options = {})
      self.instance_variable_set(:@current_partner_for_delayed, Partner.current)
      DelayProxy.new(PerformableMethod, self, options)
    end
  end
end