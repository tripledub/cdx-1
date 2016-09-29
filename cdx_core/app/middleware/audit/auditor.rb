module Audit
  # Saves all audit information to the database.
  class Auditor
    def initialize(auditable_model)
      @auditable_model = auditable_model
      @user_id         = User.current.id
    end

    def log_action(title, comment = '')
      create_log(title, comment)
    end

    def log_changes(title, comment = '')
      audit_log = create_log(title, comment)
      update_log(audit_log)
    end

    def log_status_change(title, values)
      audit_log = create_log(title, '')
      create_log_update(audit_log, 'status', values)
    end

    protected

    def create_log(title, comment)
      AuditLog.create do |log|
        log.title = title
        log.patient_id = patient_id
        log.user_id = @user_id
        log.comment = comment
        log.encounter_id = encounter_id
        log.patient_result_id = patient_result_id
      end
    end

    def update_log(audit_log)
      @auditable_model.changes.each { |key, value| create_log_update(audit_log, key, value) }
      audit_changes_to_addresses(audit_log, @auditable_model.addresses) if @auditable_model.respond_to? :addresses
    end

    def create_log_update(audit_log, field, values)
      audit_log.audit_updates.create do |log_update|
        log_update.field_name = field
        log_update.old_value  = values[0]
        log_update.new_value  = values[1]
      end
    end

    def patient_id
      @auditable_model.is_a?(Patient) ? @auditable_model.id : @auditable_model.patient.id
    end

    def encounter_id
      if @auditable_model.is_a?(Encounter)
        return @auditable_model.id
      elsif @auditable_model.is_a?(PatientResult)
        return @auditable_model.encounter.id
      end

      nil
    end

    def patient_result_id
      @auditable_model.is_a?(PatientResult) ? @auditable_model.id : nil
    end

    def audit_changes_to_addresses(audit_log, addresses)
      addresses.each_with_index do |address, index|
        address.changes.each { |key, value| create_log_update(audit_log, "#{key} - #{index}", value) }
      end
    end
  end
end
