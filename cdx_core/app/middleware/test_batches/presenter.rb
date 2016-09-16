module TestBatches
  class Presenter
    class << self
      def for_encounter(test_batch)
        {
          id: test_batch.id,
          status: test_batch.status,
          patient_results: PatientResults::Presenter.for_encounter(test_batch.patient_results)
        }
      end
    end
  end
end
