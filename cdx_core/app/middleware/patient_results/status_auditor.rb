module PatientResults
  # A new audit log is created for each patient result status changed.
  class StatusAuditor
    class << self
      def create_status_log(patient_result, values)
        Audit::Auditor.new(patient_result).log_status_change("t{patient_results.update.status_tracking}: #{sample_id(patient_result)}", values)
      end

      protected

      def sample_id(patient_result)
        patient_result.serial_number.present? ? patient_result.serial_number : patient_result.encounter.batch_id
      end
    end
  end
end
