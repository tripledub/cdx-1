module PatientResults
  class Persistence
    class << self
      def collect_sample_ids(test_batch, sample_ids)
        sample_ids.each do |sample_id|
          sample_id.each do |key, value|
            result = test_batch.patient_results.find(key)
            result.update_attribute(:serial_number, value)
          end
        end
      end
    end
  end
end
