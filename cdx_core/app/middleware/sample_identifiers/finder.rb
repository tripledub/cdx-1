module SampleIdentifiers
  # Find methods for sample identifiers
  class Finder
    class << self
      def find_first_sample_available(sample_id)
        sample_identifiers = find_all_by_sample_id(sample_id)
        sample_identifiers.each { |sample_identifier| return sample_identifier if sample_identifier.patient_results.count.zero? }
        nil
      end

      def result_sample_id_with_deleted(patient_result)
        return unless patient_result.sample_identifier_id

        SampleIdentifier.with_deleted.where(id: patient_result.sample_identifier_id).first.cpd_id_sample
      end

      def find_all_by_sample_id(sample_id)
        SampleIdentifier.where('UPPER(sample_identifiers.cpd_id_sample) = ?', sample_id.upcase).all
      end
    end
  end
end
