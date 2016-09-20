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
        testType:    patient_result.test_name.to_s,
        sampleId:    patient_result.serial_number.to_s,
        examinedBy:  patient_result.examined_by.to_s,
        comment:     patient_result.comment.to_s,
        status:      patient_result.result_status,
        completedAt: Extras::Dates::Format.datetime_with_time_zone(patient_result.completed_at),
        createdAt:   Extras::Dates::Format.datetime_with_time_zone(patient_result.created_at),
        editUrl:     Rails.application.routes.url_helpers.edit_test_batch_microscopy_result_path(patient_result.test_batch, patient_result)
      )
    end
  end
end
