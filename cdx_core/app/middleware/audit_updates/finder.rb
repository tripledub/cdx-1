module AuditUpdates
  # Finder for audit updates
  class Finder
    class << self
      def status_updates_by_test_order(test_order)
        AuditUpdate.joins(audit_log: :encounter).where("field_name = 'status'").where('audit_logs.encounter_id = ?', test_order.id)
                   .order('audit_updates.created_at asc')
      end
    end
  end
end
