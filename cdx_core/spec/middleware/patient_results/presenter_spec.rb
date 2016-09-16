require 'spec_helper'

describe PatientResults::Presenter do
  let(:encounter) { Encounter.make }
  let(:test_batch) { TestBatch.make encounter: encounter }
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
        name: patient_result.result_name,
        status: patient_result.result_status,
        completed_at: Extras::Dates::Format.datetime_with_time_zone(patient_result.completed_at),
        created_at: Extras::Dates::Format.datetime_with_time_zone(patient_result.created_at),
        updated_at: Extras::Dates::Format.datetime_with_time_zone(patient_result.updated_at)
      )
    end
  end
end
