require 'spec_helper'

describe CultureResults::Presenter do
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: user, patient: patient }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1) { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2) { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }

  before :each do
    7.times { CultureResult.make encounter: encounter }
  end

  describe 'index_table' do
    it 'should return an array of formated comments' do
      expect(described_class.index_table(CultureResult.all).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.index_table(PatientResult.all).first).to eq({
        id:                CultureResult.first.uuid,
        sampleCollectedAt: Extras::Dates::Format.datetime_with_time_zone(CultureResult.first.sample_collected_at, :full_time),
        examinedBy:        CultureResult.first.examined_by,
        resultOn:          Extras::Dates::Format.datetime_with_time_zone(CultureResult.first.result_at, :full_time),
        mediaUsed:         Extras::Select.find(CultureResult.media_options, CultureResult.first.media_used),
        serialNumber:      CultureResult.first.serial_number,
        testResult:        Extras::Select.find(CultureResult.test_result_options, CultureResult.first.test_result),
        viewLink:          Rails.application.routes.url_helpers.encounter_culture_result_path(CultureResult.first.encounter, CultureResult.first)
      })
    end
  end

  describe 'csv_query' do
    it 'should return an array of formated comments' do
      expect(CSV.parse(described_class.csv_query(CultureResult.all)).size).to eq(8)
    end

    it 'should return elements formated' do
      expect(CSV.parse(described_class.csv_query(PatientResult.all))[1]).to eq(
        [
          CultureResult.first.encounter.batch_id,
          Extras::Select.find(Encounter.status_options, CultureResult.first.encounter.status),
          Extras::Select.find(Encounter.testing_for_options, CultureResult.first.encounter.testing_for),
          CultureResult.first.uuid,
          Extras::Dates::Format.datetime_with_time_zone(CultureResult.first.sample_collected_at, :full_time),
          CultureResult.first.examined_by,
          Extras::Dates::Format.datetime_with_time_zone(CultureResult.first.result_at, :full_time),
          Extras::Select.find(CultureResult.media_options, CultureResult.first.media_used),
          CultureResult.first.serial_number,
          Extras::Select.find(CultureResult.test_result_options, CultureResult.first.test_result),
          Extras::Select.find(CultureResult.status_options, CultureResult.first.result_status),
          FeedbackMessages::Finder.find_text_from_patient_result(CultureResult.first),
          CultureResult.first.comment.to_s
        ]
      )
    end
  end
end
