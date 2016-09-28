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

        encounter.update_attribute(:status, 'samples_collected')
      end

      def update_status(patient_result, params, current_user)
        if update_patient_result(patient_result, params, current_user)
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

      def update_result(patient_result, params, current_user, audit_text)
        if patient_result.update_and_audit(params, current_user, audit_text)
          old_value = patient_result.result_status
          patient_result.update_attribute(:result_status, 'pending_approval')
          create_status_log(patient_result, current_user, [old_value, 'pending_approval'])
        else
          false
        end
      end

      protected

      def update_patient_result(patient_result, params, current_user)
        patient_result.result_status = params[:result_status] if params[:result_status].present? && can_approve_results?(params, current_user)
        patient_result.comment = params[:comment]
        patient_result.feedback_message = patient_result.encounter.institution.feedback_messages.find(params[:feedback_message_id]) if params[:feedback_message_id].to_i > 0
        create_status_log(patient_result, current_user, [patient_result.result_status_was, patient_result.result_status]) if patient_result.result_status.changed?
        patient_result.save(validate: false)
      end

      def can_approve_results?(params, current_user)
        return true unless params[:result_status] == 'completed'

        Policy.can?(Policy::Actions::APPROVE_ENCOUNTER, Encounter, current_user)
      end

      def create_status_log(patient_result, current_user, values)
        PatientResults::StatusAuditor.create_status_log(patient_result, current_user, values)
      end
    end
  end
end
