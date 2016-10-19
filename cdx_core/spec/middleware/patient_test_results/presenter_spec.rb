require 'spec_helper'

describe PatientTestResults::Presenter do
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
        MicroscopyResult.make encounter: encounter
      end
      2.times do
        CultureResult.make encounter: encounter
      end
      2.times do
        DstLpaResult.make encounter: encounter
      end
      XpertResult.make encounter: encounter
    end

    it 'should return an array of formated comments' do
      expect(described_class.patient_view(PatientResult.all).size).to eq(11)
    end

    it 'should return device test result elements formated' do
      test_result = PatientResult.first
      expect(described_class.patient_view(PatientResult.all).first).to eq({
        id:              test_result.uuid,
        name:            test_result.device.name,
        date:            Extras::Dates::Format.datetime_with_time_zone(test_result.core_fields[TestResult::START_TIME_FIELD]),
        status:          test_result.core_fields[TestResult::STATUS_FIELD],
        viewLink:        Rails.application.routes.url_helpers.test_result_path(id: test_result.uuid)
      })
    end

    it 'should return xpert test result elements formated' do
      xpert_result = PatientResult.all[10]
      expect(described_class.patient_view(PatientResult.all)[10]).to eq({
        id:              xpert_result.uuid,
        name:            'Xpert result',
        date:            Extras::Dates::Format.datetime_with_time_zone(xpert_result.sample_collected_at),
        status:          xpert_result.result_status,
        viewLink:        Rails.application.routes.url_helpers.encounter_xpert_result_path(xpert_result.encounter, xpert_result)
      })
    end

    it 'should return microscopy test result elements formated' do
      microscopy_result = PatientResult.all[5]
      expect(described_class.patient_view(PatientResult.all)[5]).to eq({
        id:              microscopy_result.uuid,
        name:            'Microscopy result',
        date:            Extras::Dates::Format.datetime_with_time_zone(microscopy_result.sample_collected_at),
        status:          microscopy_result.result_status,
        viewLink:        Rails.application.routes.url_helpers.encounter_microscopy_result_path(microscopy_result.encounter, microscopy_result)
      })
    end

    it 'should return culture test result elements formated' do
      culture_result = PatientResult.all[7]
      expect(described_class.patient_view(PatientResult.all)[7]).to eq({
        id:              culture_result.uuid,
        name:            'Culture result',
        date:            Extras::Dates::Format.datetime_with_time_zone(culture_result.sample_collected_at),
        status:          culture_result.result_status,
        viewLink:        Rails.application.routes.url_helpers.encounter_culture_result_path(culture_result.encounter, culture_result)
      })
    end

    it 'should return dst/lpa test result elements formated' do
      dst_lpa_result = PatientResult.all[9]
      expect(described_class.patient_view(PatientResult.all)[9]).to eq({
        id:              dst_lpa_result.uuid,
        name:            'Dst/Lpa result',
        date:            Extras::Dates::Format.datetime_with_time_zone(dst_lpa_result.sample_collected_at),
        status:          dst_lpa_result.result_status,
        viewLink:        Rails.application.routes.url_helpers.encounter_dst_lpa_result_path(dst_lpa_result.encounter, dst_lpa_result)
      })
    end
  end
end
