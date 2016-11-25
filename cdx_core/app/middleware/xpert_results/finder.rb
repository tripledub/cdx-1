module XpertResults
  # Find methods for xpert results
  class Finder
    class << self
      def available_test(sample_identifiers)
        sample_identifiers.each do |sample_identifier|
          xpert_result = sample_identifier.sample.encounter.xpert_results.where('patient_results.sample_identifier_id IS NULL').first
          return [xpert_result, sample_identifier] if xpert_result.present?
        end
      end
    end
  end
end
