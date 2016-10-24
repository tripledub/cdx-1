module SampleIdentifiers
  # Find methods for sample identifiers
  class Finder
    class << self
      def find_all_samples_available(sample_id)
        SampleIdentifier.where('UPPER(sample_identifiers.cpd_id_sample) = ?', sample_id.upcase).all
      end

      def result_sample_id_with_deleted(patient_result)
        return unless patient_result.sample_identifier_id

        SampleIdentifier.with_deleted.where(id: patient_result.sample_identifier_id).first.cpd_id_sample
      end
    end
  end
end
