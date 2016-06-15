module Audit
  class Auditor
    def initialize(patient, user)
      @patient = patient
      @user    = user
    end

    def create_log(title, comment='')
      add_new_log(title, comment)
    end

    def update_log(title, comment='')
      audit_log = add_new_log(title, comment)

      log_changes(audit_log, @patient)
    end

    protected

    def add_new_log(title, comment)
      AuditLog.create do |log|
        log.title   = title
        log.patient = @patient
        log.user    = @user
        log.comment = comment
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
