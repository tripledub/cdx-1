module Audit
  class  EncounterTestAuditor < Auditor

    def log_action(title, comment='', encounter, test)
      create_log(title, comment, encounter, test)
    end

    def log_changes(title, comment='', encounter, test)
      audit_log = create_log(title, comment, encounter, test)
      update_log(audit_log)
    end

    def create_log(title, comment, encounter, test)
      EncounterTestAuditLog.create do |log|
        log.title = title
        log.patient_id = patient_id
        log.user_id = @user_id
        log.comment = comment
        log.encounter_id = encounter.id
        log.requested_test_id = test.id
      end
    end
  end
end
