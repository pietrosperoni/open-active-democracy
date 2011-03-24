Delayed::Worker.logger = Rails.logger

module Delayed
  class PerformableMethod

    def perform
      Government.current = Government.last
      object.send(method_name, *args) if object
    rescue ActiveRecord::RecordNotFound
      # We cannot do anything about objects which were deleted in the meantime
      true
    end
    
  end
end