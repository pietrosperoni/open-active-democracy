class AddPriorityExternalSessionId < ActiveRecord::Migration
  def self.up
    add_column :priorities, :external_session_id, :integer
    Priority.transaction do
      Priority.all.each do |pri|
        if pri.external_link
          uri_params = CGI.parse(URI.parse(pri.external_link).query)
          pri.external_session_id = uri_params["ltg"].first
          pri.save(false)
        end
      end
    end
  end
end
