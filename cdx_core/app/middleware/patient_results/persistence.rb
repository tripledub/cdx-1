module PatientResults
  class Persistence
    class << self
      def collect_sample_ids(test_batch, sample_ids)
        sample_ids.each do |sample_id|
          result = test_batch.patient_results.find(sample_id[0])
          result.update_attribute(:serial_number, sample_id[1])
        end

        test_batch.update_attribute(:status, 'samples_collected')
      end

      def update_status(patient_result, params)
        if update_patient_result(patient_result, params)
          [
            {
              resultStatus: patient_result.result_status,
              testBatchStatus: patient_result.test_batch.status,
              testOrderStatus: patient_result.test_batch.encounter.status
             },
             :ok
          ]
        else
          [patient_result.errors.messages, :unprocessable_entity]
        end
      end

      def update_result(patient_result, params, current_user, audit_text)
        if patient_result.update_and_audit(params, current_user, audit_text)
          patient_result.update_attribute(:result_status, 'pending_approval')
        else
          false
        end
      end

      protected

      def update_patient_result(patient_result, params)
        patient_result.result_status = params[:result_status] if params[:result_status].present?
        patient_result.comment = params[:comment]
        patient_result.feedback_message = patient_result.test_batch.institution.feedback_messages.find(params[:feedback_message_id]) if params[:feedback_message_id].to_i > 0
        patient_result.save(validate: false)
      end
    end
  end
end
