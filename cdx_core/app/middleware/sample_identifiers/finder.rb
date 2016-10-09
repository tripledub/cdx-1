module SampleIdentifiers
  # Find methods for sample identifiers
  class Finder
    class << self
      def find_first_sample_available(sample_id)
        sample_identifiers = find_all_by_sample_id(sample_id)
        sample_identifiers.each { |sample_identifier| return sample_identifier if sample_identifier.patient_results.count.zero? }
        nil
      end

      def find_all_by_sample_id(sample_id)
        SampleIdentifier.where('sample_identifiers.lab_sample_id = ?', sample_id).all
      end
    end
  end
end
