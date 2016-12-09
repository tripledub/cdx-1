require 'spec_helper'

describe MicroscopyResults::Presenter do
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: user, patient: patient }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1) { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2) { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }

  before :each do
    7.times { MicroscopyResult.make encounter: encounter }
  end

  describe 'index_table' do
    it 'should return an array of formated comments' do
      expect(described_class.index_table(MicroscopyResult.all).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.index_table(PatientResult.all).first).to eq({
        id:                MicroscopyResult.first.uuid,
        sampleCollectedAt: Extras::Dates::Format.datetime_with_time_zone(MicroscopyResult.first.sample_collected_at, :full_time),
        examinedBy:        MicroscopyResult.first.examined_by,
        resultOn:          Extras::Dates::Format.datetime_with_time_zone(MicroscopyResult.first.result_at, :full_time),
        specimenType:      MicroscopyResult.first.specimen_type.blank? ? "" : I18n.t("test_results.index.specimen_type.#{MicroscopyResult.first.specimen_type}"),
        serialNumber:      MicroscopyResult.first.serial_number,
        testResult:        Extras::Select.find(MicroscopyResult.test_result_options, MicroscopyResult.first.test_result),
        appearance:        Extras::Select.find(MicroscopyResult.visual_appearance_options, MicroscopyResult.first.appearance),
        viewLink:          Rails.application.routes.url_helpers.encounter_microscopy_result_path(MicroscopyResult.first.encounter, MicroscopyResult.first)
      })
    end
  end

  describe 'csv_query' do
    it 'should return an array of formated comments' do
      expect(CSV.parse(described_class.csv_query(MicroscopyResult.all)).size).to eq(8)
    end

    it 'should return elements formated' do
      expect(CSV.parse(described_class.csv_query(PatientResult.all))[1]).to eq(
        [
          MicroscopyResult.first.encounter.batch_id,
          MicroscopyResult.first.uuid,
          Extras::Select.find(Encounter.status_options, MicroscopyResult.first.encounter.status),
          Extras::Select.find(Encounter.testing_for_options, MicroscopyResult.first.encounter.testing_for),
          MicroscopyResult.first.examined_by,
          Extras::Dates::Format.datetime_with_time_zone(MicroscopyResult.first.sample_collected_at, :full_time_with_timezone),
          Extras::Dates::Format.datetime_with_time_zone(MicroscopyResult.first.result_at, :full_time_with_timezone),
          MicroscopyResult.first.specimen_type.blank? ? '' : I18n.t("test_results.index.specimen_type.#{MicroscopyResult.first.specimen_type}"),
          Extras::Select.find(MicroscopyResult.test_result_options, MicroscopyResult.first.test_result),
          Extras::Select.find(MicroscopyResult.visual_appearance_options, MicroscopyResult.first.appearance),
          Extras::Select.find(MicroscopyResult.status_options, MicroscopyResult.first.result_status),
          FeedbackMessages::Finder.find_text_from_patient_result(MicroscopyResult.first),
          MicroscopyResult.first.comment.to_s
        ]
      )
    end
  end

end
