module PatientResults
  # A new audit log is created for each patient result status changed.
  class StatusAuditor
    class << self
      def create_status_log(patient_result, user, values)
        Audit::Auditor.new(patient_result, user).log_status_change('t{patient_results.update.status_tracking}', values)
      end
    end
  end
end
