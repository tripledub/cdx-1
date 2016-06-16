module Audit
  class Auditor
    def initialize(patient_id, user_id)
      @patient_id = patient_id
      @user_id    = user_id
    end

    def create(title, comment='')
      create_log(title, comment)
    end

    def update(title, comment='')
      audit_log = create_log(title, comment)

      log_changes(audit_log, @patient)
    end

    def destroy(title, comment='')
      create_log(title, comment)
    end

    protected

    def create_log(title, comment)
      AuditLog.create do |log|
        log.title      = title
        log.patient_id = @patient_id
        log.user_id    = @user_id
        log.comment    = comment
      end
    end

    def log_changes(audit_log, auditing_model)
      auditing_model.changes.each { |key, value| create_log_update(audit_log, key, value) }
    end

    def create_log_update(audit_log, field, values)
      audit_log.audit_updates.create do |log_update|
        log_update.field_name = field
        log_update.old_value  = values[0]
        log_update.new_value  = values[1]
      end
    end
  end
end
