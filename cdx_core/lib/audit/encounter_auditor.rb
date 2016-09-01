module Audit
  class  EncounterAuditor < Auditor

    def log_action(title, comment='', encounter)
      create_log(title, comment, encounter)
    end

    def log_changes(title, comment='', encounter)
      audit_log = create_log(title, comment, encounter)
      update_log(audit_log)
    end

    def create_log(title, comment, encounter)
      EncounterAuditLog.create do |log|
        log.title = title
        log.patient_id = patient_id if encounter.patient != nil
        log.user_id = @user_id
        log.comment = comment
        log.encounter_id = encounter.id
      end
    end
  end
end
