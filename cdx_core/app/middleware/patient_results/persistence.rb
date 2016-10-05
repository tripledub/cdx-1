module PatientResults
  # Update logic for patient results
  class Persistence
    class << self
      def build_requested_tests(encounter, tests_requested = '|')
        tests_requested.split('|').each do |name|
          new_result = PatientResults::Finder.instance_from_string(name)
          new_result.result_name = name
          encounter.patient_results << new_result
        end
      end

      def collect_sample_ids(encounter, sample_ids)
        sample_ids.each do |sample_id|
          result = encounter.patient_results.find(sample_id[0])
          result.update_attribute(:serial_number, sample_id[1])
        end

        TestOrders::Status.update_and_log(encounter, 'samples_collected')
      end

      def update_status(patient_result, params)
        if update_patient_result(patient_result, params)
          [
            {
              resultStatus: patient_result.result_status,
              testOrderStatus: patient_result.encounter.status
            },
            :ok
          ]
        else
          [patient_result.errors.messages, :unprocessable_entity]
        end
      end

      def update_result(patient_result, params, audit_text)
        patient_result.update_and_audit(params, audit_text) ? update_status_and_log(patient_result, 'pending_approval') : false
      end

      protected

      def update_patient_result(patient_result, params)
        patient_result.comment = params[:comment] if params[:comment].present?
        patient_result.feedback_message =
          patient_result.encounter.institution.feedback_messages.find(params[:feedback_message_id]) if params[:feedback_message_id].to_i > 0
        update_status_and_log(patient_result, params[:result_status])
        patient_result.save(validate: false)
      end

      def can_update_results?(result_status)
        return true unless result_status == 'completed'

        Policy.can?(Policy::Actions::APPROVE_ENCOUNTER, Encounter, User.current)
      end

      def update_status_and_log(patient_result, new_status)
        return false unless new_status.present? && can_update_results?(new_status)

        PatientResults::StatusAuditor.create_status_log(patient_result, [patient_result.result_status, new_status])
        patient_result.update_attribute(:result_status, new_status)
      end
    end
  end
end
