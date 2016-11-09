module SampleIdentifiers
  # Handles the presentation of a sample identifier
  class Presenter
    class << self
      def orphan_sample_id(test_result)
        test_result.sample_identifiers.map(&:entity_id).join(' / ')
      end
    end
  end
end
