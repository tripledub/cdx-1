require 'spec_helper'

describe Presenters::PatientTestResults do
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:site)           { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution }
  let(:device)         { Device.make  institution: institution, site: site }
  let(:encounter)      { Encounter.make institution: institution , user: user, patient: patient }

  describe 'patient_view' do
    before :each do
      4.times do
        TestResult.make patient: patient, institution: institution, device: device
      end
      2.times do
        requested_test = RequestedTest.make encounter: encounter
        MicroscopyResult.make requested_test: requested_test
      end
      2.times do
        requested_test = RequestedTest.make encounter: encounter
        CultureResult.make requested_test: requested_test
      end
      2.times do
        requested_test = RequestedTest.make encounter: encounter
        DstLpaResult.make requested_test: requested_test
      end
      requested_test = RequestedTest.make encounter: encounter
      XpertResult.make requested_test: requested_test
    end

    it 'should return an array of formated comments' do
      expect(described_class.patient_view(PatientResult.all).size).to eq(11)
    end

    it 'should return device test result elements formated' do
      test_result = PatientResult.first
      expect(described_class.patient_view(PatientResult.all).first).to eq({
        id:              test_result.uuid,
        name:            test_result.core_fields[TestResult::NAME_FIELD],
        date:            Extras::Dates::Format.datetime_with_time_zone(test_result.core_fields[TestResult::START_TIME_FIELD]),
        status:          test_result.core_fields[TestResult::STATUS_FIELD],
        viewLink:        Rails.application.routes.url_helpers.test_result_path(id: test_result.uuid)
      })
    end

    it 'should return xpert test result elements formated' do
      xpert_result = PatientResult.all[10]
      expect(described_class.patient_view(PatientResult.all)[10]).to eq({
        id:              xpert_result.uuid,
        name:            xpert_result.specimen_type,
        date:            Extras::Dates::Format.datetime_with_time_zone(xpert_result.sample_collected_on),
        status:          xpert_result.trace,
        viewLink:        Rails.application.routes.url_helpers.requested_test_xpert_result_path(requested_test_id: xpert_result.requested_test.id)
      })
    end

    it 'should return microscopy test result elements formated' do
      microscopy_result = PatientResult.all[5]
      expect(described_class.patient_view(PatientResult.all)[5]).to eq({
        id:              microscopy_result.uuid,
        name:            microscopy_result.specimen_type,
        date:            Extras::Dates::Format.datetime_with_time_zone(microscopy_result.sample_collected_on),
        status:          Extras::Select.find(MicroscopyResult.test_result_options, microscopy_result.test_result),
        viewLink:        Rails.application.routes.url_helpers.requested_test_microscopy_result_path(requested_test_id: microscopy_result.requested_test.id)
      })
    end

    it 'should return culture test result elements formated' do
      culture_result = PatientResult.all[7]
      expect(described_class.patient_view(PatientResult.all)[7]).to eq({
        id:              culture_result.uuid,
        name:            Extras::Select.find(CultureResult.media_options, culture_result.media_used),
        date:            Extras::Dates::Format.datetime_with_time_zone(culture_result.sample_collected_on),
        status:          Extras::Select.find(CultureResult.test_result_options, culture_result.test_result),
        viewLink:        Rails.application.routes.url_helpers.requested_test_culture_result_path(requested_test_id: culture_result.requested_test.id)
      })
    end

    it 'should return dst/lpa test result elements formated' do
      dst_lpa_result = PatientResult.all[9]
      expect(described_class.patient_view(PatientResult.all)[9]).to eq({
        id:              dst_lpa_result.uuid,
        name:            Extras::Select.find(DstLpaResult.method_options, dst_lpa_result.media_used),
        date:            Extras::Dates::Format.datetime_with_time_zone(dst_lpa_result.sample_collected_on),
        status:          dst_lpa_result.serial_number,
        viewLink:        Rails.application.routes.url_helpers.requested_test_dst_lpa_result_path(requested_test_id: dst_lpa_result.requested_test.id)
      })
    end
  end
end
