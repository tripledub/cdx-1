module TestBatches
  class Presenter
    class << self
      def for_encounter(test_batch, current_user)
        {
          id: test_batch.id,
          batchId: test_batch.encounter.batch_id,
          paymentDone: test_batch.payment_done,
          status: test_batch.status,
          userCanApprove: Policy.can?(Policy::Actions::APPROVE_ENCOUNTER, Encounter, current_user),
          patientResults: PatientResults::Presenter.for_encounter(test_batch.patient_results)
        }
      end
    end
  end
end
