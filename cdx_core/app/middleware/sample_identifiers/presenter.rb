module SampleIdentifiers
  # Handles the presentation of a sample identifier
  class Presenter
    class << self
      def available_samples(encounter)
        SampleIdentifier.joins(:sample).where('samples.encounter_id = ?', encounter.id).pluck(:lab_sample_id, :id)
      end
    end
  end
end
