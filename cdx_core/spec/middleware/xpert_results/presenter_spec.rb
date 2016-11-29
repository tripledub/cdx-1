require 'spec_helper'

describe XpertResults::Presenter do
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: user, patient: patient }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1) { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2) { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }

  before :each do
    7.times { XpertResult.make encounter: encounter }
  end

  describe 'index_table' do
    it 'should return an array of formated comments' do
      expect(described_class.index_table(XpertResult.all).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.index_table(XpertResult.all).first).to eq({
        id:                XpertResult.first.uuid,
        sampleCollectedAt: Extras::Dates::Format.datetime_with_time_zone(XpertResult.first.sample_collected_at, :full_time),
        examinedBy:        XpertResult.first.examined_by,
        resultOn:          Extras::Dates::Format.datetime_with_time_zone(XpertResult.first.result_at, :full_time),
        tuberculosis:      Extras::Select.find(XpertResult.tuberculosis_options, XpertResult.first.tuberculosis),
        rifampicin:        Extras::Select.find(XpertResult.rifampicin_options, XpertResult.first.rifampicin),
        trace:             Extras::Select.find(XpertResult.trace_options, XpertResult.first.trace),
        viewLink:          Rails.application.routes.url_helpers.encounter_xpert_result_path(XpertResult.first.encounter, XpertResult.first)
      })
    end
  end

  describe 'csv_query' do
    it 'should return an array of formated comments' do
      expect(CSV.parse(described_class.csv_query(XpertResult.all)).size).to eq(8)
    end

    it 'should return elements formated' do
      expect(CSV.parse(described_class.csv_query(XpertResult.all))[1]).to eq(
        [
          XpertResult.first.encounter.batch_id,
          XpertResult.first.uuid,
          Extras::Select.find(Encounter.status_options, XpertResult.first.encounter.status),
          Extras::Select.find(Encounter.testing_for_options, XpertResult.first.encounter.testing_for),
          XpertResult.first.examined_by,
          Extras::Dates::Format.datetime_with_time_zone(XpertResult.first.sample_collected_at, :full_time),
          Extras::Dates::Format.datetime_with_time_zone(XpertResult.first.result_at, :full_time),
          Extras::Select.find(XpertResult.tuberculosis_options, XpertResult.first.tuberculosis).to_s,
          Extras::Select.find(XpertResult.rifampicin_options, XpertResult.first.rifampicin),
          Extras::Select.find(XpertResult.trace_options, XpertResult.first.trace),
          Extras::Select.find(XpertResult.status_options, XpertResult.first.result_status),
          FeedbackMessages::Finder.find_text_from_patient_result(XpertResult.first),
          XpertResult.first.comment.to_s
        ]
      )
    end
  end
end
