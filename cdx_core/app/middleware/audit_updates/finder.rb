module AuditUpdates
  # Finder for audit updates
  class Finder
    class << self
      def status_updates_by_test_order(test_order)
        AuditUpdate.joins(audit_log: :encounter).where("field_name = 'status'").where('audit_logs.encounter_id = ? AND audit_logs.patient_result_id IS NULL', test_order.id)
                   .order('audit_updates.created_at asc')
      end

      def status_updates_by_patient_result(patient_result)
        AuditUpdate.joins(audit_log: :encounter).where("field_name = 'status'").where('audit_logs.patient_result_id = ?', patient_result.id)
                   .order('audit_updates.created_at asc')
      end
    end
  end
end
