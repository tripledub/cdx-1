require 'spec_helper'

describe TestBatches::Presenter do
  let(:encounter)  { Encounter.make }
  let(:test_batch) { TestBatch.make encounter: encounter }
  let!(:requested_tests) {
    MicroscopyResult.make test_batch: test_batch
    CultureResult.make test_batch: test_batch
    DstLpaResult.make test_batch: test_batch
  }

  describe 'for_encounter' do
    subject { described_class.for_encounter(encounter.test_batch) }

    it 'returns an Hash' do
      expect(subject).to be_a(Hash)
    end

    it 'returns all elements correctly formatted' do
      test_batch = encounter.test_batch
      expect(subject).to eq(
        id: test_batch.id,
        batchId: test_batch.encounter.batch_id,
        paymentDone: test_batch.payment_done,
        status: test_batch.status,
        patientResults: PatientResults::Presenter.for_encounter(test_batch.patient_results)
      )
    end
  end
end
