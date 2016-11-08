require 'spec_helper'

describe TestResults::Presenter do
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:site)           { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution }
  let(:device)         { Device.make  institution: institution, site: site }
  let!(:results) do
    4.times do
      TestResult.make patient: patient, institution: institution,
        device: device, core_fields: { 'assays' =>['condition' => 'mtb', 'result' => 'positive'] }
    end
  end

  describe 'patient_view' do
    it 'should return an array of formated comments' do
      expect(described_class.index_table(PatientResult.all).size).to eq(4)
    end

    it 'should return device test result elements formated' do
      test_result = PatientResult.first
      expect(described_class.index_table(PatientResult.all).first).to eq(
        {
          id: test_result.id,
          name: test_result.result_name,
          assays: Assays::Presenter.all_results(test_result),
          siteName: Sites::Presenter.site_name(test_result.site),
          deviceName: Devices::Presenter.device_name_and_serial_number(test_result.device),
          sampleId: SampleIdentifiers::Presenter.orphan_sample_id(test_result),
          status: '',
          collectedAt: Extras::Dates::Format.datetime_with_time_zone(test_result.sample_collected_at),
          resultAt: Extras::Dates::Format.datetime_with_time_zone(test_result.result_at),
          viewLink: Rails.application.routes.url_helpers.test_result_path(test_result)
        }
      )
    end
  end
end
