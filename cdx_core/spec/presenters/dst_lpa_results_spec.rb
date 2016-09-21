require 'spec_helper'

describe Presenters::DstLpaResults do
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: user, patient: patient, test_batch: TestBatch.make(institution: institution) }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1) { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2) { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }

  describe 'index_table' do
    before :each do
      7.times { DstLpaResult.make test_batch: encounter.test_batch }
    end

    it 'should return an array of formated comments' do
      expect(described_class.index_table(DstLpaResult.all).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.index_table(DstLpaResult.all).first).to eq({
        id:                DstLpaResult.first.uuid,
        sampleCollectedOn: Extras::Dates::Format.datetime_with_time_zone(DstLpaResult.first.sample_collected_on),
        examinedBy:        DstLpaResult.first.examined_by,
        resultOn:          Extras::Dates::Format.datetime_with_time_zone(DstLpaResult.first.result_on),
        mediaUsed:         Extras::Select.find(DstLpaResult.method_options, DstLpaResult.first.media_used),
        serialNumber:      DstLpaResult.first.serial_number,
        resultH:           Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_h),
        resultR:           Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_r),
        resultE:           Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_e),
        resultS:           Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_s),
        resultAmk:         Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_amk),
        resultKm:          Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_km),
        resultCm:          Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_cm),
        resultFq:          Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_fq),
        viewLink:          Rails.application.routes.url_helpers.requested_test_dst_lpa_result_path(requested_test_id: DstLpaResult.first.requested_test.id)
      })
    end
  end
end
