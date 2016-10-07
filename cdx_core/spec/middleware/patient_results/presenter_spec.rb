require 'spec_helper'

describe PatientResults::Presenter do
  let(:encounter) { Encounter.make }

  describe 'for_encounter' do
    before :each do
      MicroscopyResult.make encounter: encounter, feedback_message: FeedbackMessage.make(institution: encounter.institution), sample_identifier: SampleIdentifier.make
      CultureResult.make encounter: encounter
      DstLpaResult.make encounter: encounter
      encounter.reload
    end

    subject { described_class.for_encounter(encounter.patient_results) }

    it 'returns an array of formatted test requests' do
      expect(subject).to be_a(Array)
      expect(subject.count).to eq(3)
    end

    it 'returns all elements correctly formatted' do
      patient_result = MicroscopyResult.first
      expect(subject.first).to eq(
        id:          patient_result.id,
        testType:    patient_result.test_name.to_s,
        sampleId:    patient_result.sample_identifier.lab_sample_id.to_s,
        examinedBy:  patient_result.examined_by.to_s,
        comment:     patient_result.comment.to_s,
        status:      patient_result.result_status,
        completedAt: Extras::Dates::Format.datetime_with_time_zone(patient_result.completed_at),
        createdAt:   Extras::Dates::Format.datetime_with_time_zone(patient_result.created_at),
        feedbackMessage: FeedbackMessages::Finder.find_text_from_patient_result(patient_result),
        editUrl:         Rails.application.routes.url_helpers.edit_encounter_microscopy_result_path(patient_result.encounter, patient_result),
        showResultUrl:   Rails.application.routes.url_helpers.encounter_microscopy_result_path(patient_result.encounter, patient_result)
      )
    end
  end
end
