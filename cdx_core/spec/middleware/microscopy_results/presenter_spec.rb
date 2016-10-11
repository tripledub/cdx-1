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

  describe 'index_table' do
    before :each do
      7.times { MicroscopyResult.make encounter: encounter }
    end

    it 'should return an array of formated comments' do
      expect(described_class.index_table(MicroscopyResult.all).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.index_table(PatientResult.all).first).to eq({
        id:                MicroscopyResult.first.uuid,
        sampleCollectedOn: Extras::Dates::Format.datetime_with_time_zone(MicroscopyResult.first.sample_collected_on),
        examinedBy:        MicroscopyResult.first.examined_by,
        resultOn:          Extras::Dates::Format.datetime_with_time_zone(MicroscopyResult.first.result_on),
        specimenType:      MicroscopyResult.first.specimen_type,
        serialNumber:      MicroscopyResult.first.serial_number,
        testResult:        Extras::Select.find(MicroscopyResult.test_result_options, MicroscopyResult.first.test_result),
        appearance:        Extras::Select.find(MicroscopyResult.visual_appearance_options, MicroscopyResult.first.appearance),
        viewLink:          Rails.application.routes.url_helpers.encounter_microscopy_result_path(MicroscopyResult.first.encounter, MicroscopyResult.first)
      })
    end
  end
end
