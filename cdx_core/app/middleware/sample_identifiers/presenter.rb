module SampleIdentifiers
  # Handles the presentation of a sample identifier
  class Presenter
    class << self
      def orphan_sample_id(test_result)
        SampleIdentifier.where(id: test_result.id).all.map(&:entity_id).join(' / ')
      end

      def for_encounter(encounter)
        encounter.samples.map { |sample| sample.sample_identifiers.map(&:cpd_id_sample).compact.join(', ') }.compact.join(', ')
      end
    end
  end
end
