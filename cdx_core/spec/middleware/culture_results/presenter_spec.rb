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

  describe 'index_table' do
    before :each do
      7.times { CultureResult.make encounter: encounter }
    end

    it 'should return an array of formated comments' do
      expect(described_class.index_table(CultureResult.all).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.index_table(PatientResult.all).first).to eq({
        id:                CultureResult.first.uuid,
        sampleCollectedOn: Extras::Dates::Format.datetime_with_time_zone(CultureResult.first.sample_collected_at),
        examinedBy:        CultureResult.first.examined_by,
        resultOn:          Extras::Dates::Format.datetime_with_time_zone(CultureResult.first.result_at),
        mediaUsed:         Extras::Select.find(CultureResult.media_options, CultureResult.first.media_used),
        serialNumber:      CultureResult.first.serial_number,
        testResult:        Extras::Select.find(CultureResult.test_result_options, CultureResult.first.test_result),
        viewLink:          Rails.application.routes.url_helpers.encounter_culture_result_path(CultureResult.first.encounter, CultureResult.first)
      })
    end
  end
end
