module PrioritiesHelper

  def has_process_documents?
    #TODO: Create optimized ActiveRecrods/SQL for this
    found = false
    @priority.priority_processes.each do |process|
      process.process_documents.each do |document|
        found = true
      end
    end
    found
  end
end