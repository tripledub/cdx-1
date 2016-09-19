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
    end
  end
end
