module SampleIdentifiers
  # Handles the presentation of a sample identifier
  class Presenter
    class << self
      def available_samples(encounter)
        assigned_samples = encounter.patient_results.map(&:sample_identifier_id).compact
        assigned_samples << 0 if assigned_samples.empty?
        SampleIdentifier.joins(:sample).where('samples.encounter_id = ?', encounter.id)
                        .where('sample_identifiers.id NOT IN(?)', assigned_samples).pluck(:lab_sample_id, :id)
      end
    end
  end
end
