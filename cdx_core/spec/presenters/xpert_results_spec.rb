require 'spec_helper'

describe Presenters::XpertResults do
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
      7.times { XpertResult.make encounter: encounter }
    end

    it 'should return an array of formated comments' do
      expect(described_class.index_table(XpertResult.all).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.index_table(XpertResult.all).first).to eq({
        id:                XpertResult.first.uuid,
        sampleCollectedOn: Extras::Dates::Format.datetime_with_time_zone(XpertResult.first.sample_collected_on),
        examinedBy:        XpertResult.first.examined_by,
        resultOn:          Extras::Dates::Format.datetime_with_time_zone(XpertResult.first.result_on),
        tuberculosis:      Extras::Select.find(XpertResult.tuberculosis_options, XpertResult.first.specimen_type),
        rifampicin:        Extras::Select.find(XpertResult.rifampicin_options, XpertResult.first.serial_number),
        trace:             Extras::Select.find(XpertResult.trace_options, XpertResult.first.trace),
        viewLink:          Rails.application.routes.url_helpers.encounter_xpert_result_path(XpertResult.first.encounter, XpertResult.first)
      })
    end
  end
end
