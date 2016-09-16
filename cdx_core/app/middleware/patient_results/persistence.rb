module PatientResults
  class Persistence
    class << self
      def collect_sample_ids(test_batch, sample_ids)
        sample_ids.each do |sample_id|
          result = test_batch.patient_results.find(sample_id['id'])
          result.update_attribute(:serial_number, sample_id['sample'])
        end
      end
    end
  end
end
