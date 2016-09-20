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
        if patient_result.update_attribute(:result_status, params[:result_status].to_s) && patient_result.update_attribute(:comment, params[:comment].to_s)
          [patient_result.result_status, :ok]
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
    end
  end
end
