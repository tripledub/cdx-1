require 'spec_helper'

describe PatientResults::Presenter do
  let(:encounter) { Encounter.new }
  let(:test_batch) { encounter.test_batch }
  let!(:requested_tests) {
    MicroscopyResult.make test_batch: test_batch
    CultureResult.make test_batch: test_batch
    DstLpaResult.make test_batch: test_batch
  }

  describe 'for_encounter' do
    subject { PatientResults::Presenter.for_encounter(test_batch.patient_results) }

    it 'returns an array of formatted test requests' do
      expect(subject).to be_a(Array)
      expect(subject.size).to eq(3)
    end

    it 'returns all elements correctly formatted' do
      patient_result = PatientResult.first
      expect(subject.first).to eq(
        id: patient_result.id,
        turnaround: patient_result.turnaround,
        comment: patient_result.comment,
        name: patient_result.name,
        status: patient_result.status,
        completed_at: patient_result.completed_at,
        created_at: patient_result.created_at,
        updated_at: patient_result.updated_at
      )
    end
  end
end
