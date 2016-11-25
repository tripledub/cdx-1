require 'spec_helper'

describe DstLpaResults::Presenter do
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: user, patient: patient }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1) { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2) { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }

  before :each do
    7.times { DstLpaResult.make encounter: encounter }
  end

  describe 'index_table' do
    it 'should return an array of formated comments' do
      expect(described_class.index_table(DstLpaResult.all).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.index_table(DstLpaResult.all).first).to eq({
        id:                DstLpaResult.first.uuid,
        sampleCollectedAt: Extras::Dates::Format.datetime_with_time_zone(DstLpaResult.first.sample_collected_at, :full_time),
        examinedBy:        DstLpaResult.first.examined_by,
        resultOn:          Extras::Dates::Format.datetime_with_time_zone(DstLpaResult.first.result_at, :full_time),
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
        viewLink:          Rails.application.routes.url_helpers.encounter_dst_lpa_result_path(DstLpaResult.first.encounter, DstLpaResult.first)
      })
    end

    describe 'csv_query' do
      it 'should return an array of formated comments' do
        expect(CSV.parse(described_class.csv_query(DstLpaResult.all)).size).to eq(8)
      end

      it 'should return elements formated' do
        expect(CSV.parse(described_class.csv_query(DstLpaResult.all))[1]).to eq(
          [
            DstLpaResult.first.encounter.batch_id,
            Extras::Select.find(Encounter.status_options, DstLpaResult.first.encounter.status),
            Extras::Select.find(Encounter.testing_for_options, DstLpaResult.first.encounter.testing_for),
            DstLpaResult.first.uuid,
            Extras::Dates::Format.datetime_with_time_zone(DstLpaResult.first.sample_collected_at, :full_time),
            DstLpaResult.first.examined_by,
            Extras::Dates::Format.datetime_with_time_zone(DstLpaResult.first.result_at, :full_time),
            Extras::Select.find(DstLpaResult.method_options, DstLpaResult.first.media_used),
            DstLpaResult.first.serial_number,
            Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_h),
            Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_r),
            Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_e),
            Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_s),
            Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_amk),
            Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_km),
            Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_cm),
            Extras::Select.find(DstLpaResult.dst_lpa_options, DstLpaResult.first.results_fq),
            Extras::Select.find(DstLpaResult.status_options, DstLpaResult.first.result_status),
            FeedbackMessages::Finder.find_text_from_patient_result(DstLpaResult.first),
            DstLpaResult.first.comment.to_s
          ]
        )
      end
    end
  end
end
