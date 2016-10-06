module SampleIdentifiers
  # Find methods for sample identifiers
  class Finder
    class << self
      def find_all_by_sample_id(sample_id)
        SampleIdentifier.where('sample_identifiers.lab_sample_id = ?', sample_id).all
      end
    end
  end
end
