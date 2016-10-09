module XpertResults
  # Find methods for xpert results
  class Finder
    class << self
      def available_test(encounter)
        encounter.xpert_results.where('patient_results.sample_identifier_id IS NULL').first
      end
    end
  end
end
