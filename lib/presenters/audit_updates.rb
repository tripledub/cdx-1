class Presenters::AuditUpdates
  class << self
    def patient_view(audit_updates)
      audit_updates.map do |audit_update|
        {
          id:        audit_update.id,
          fieldName: audit_update.field_name,
          oldValue:  audit_update.old_value,
          newValue:  audit_update.new_value
        }
      end
    end
  end
end
