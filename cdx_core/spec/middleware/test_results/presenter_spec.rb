require 'spec_helper'

describe TestResults::Presenter do
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:site)           { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution }
  let(:device)         { Device.make  institution: institution, site: site }
  let!(:results) do
    4.times do
      TestResult.make patient: patient, institution: institution, device: device, result_status: 'success',
        core_fields: { 'assays' => ['condition' => 'mtb', 'result' => 'positive'] }
    end
  end

  describe 'patient_view' do
    it 'should return an array of formated comments' do
      expect(described_class.index_table(TestResult.all).size).to eq(4)
    end

    it 'should return device test result elements formated' do
      test_result = TestResult.first
      expect(described_class.index_table(TestResult.all).first).to eq(
        {
          id: test_result.id,
          name: test_result.result_name,
          assays: Assays::Presenter.all_results(test_result),
          siteName: Sites::Presenter.site_name(test_result.site),
          deviceName: Devices::Presenter.device_name_and_serial_number(test_result.device),
          sampleId: SampleIdentifiers::Presenter.orphan_sample_id(test_result),
          status: I18n.t('select.test_results.result_status.' + test_result.result_status),
          collectedAt: Extras::Dates::Format.datetime_with_time_zone(test_result.sample_collected_at, :full_time),
          resultAt: Extras::Dates::Format.datetime_with_time_zone(test_result.result_at, :full_time),
          viewLink: Rails.application.routes.url_helpers.test_result_path(test_result)
        }
      )
    end
  end

  describe 'csv_query' do
    it 'should return an array of formated comments' do
      expect(CSV.parse(described_class.csv_query(TestResult.all)).size).to eq(5)
    end

    it 'should return elements formated' do
      expect(CSV.parse(described_class.csv_query(TestResult.all))[1]).to eq(
        [
          TestResult.first.test_id,
          Extras::Dates::Format.datetime_with_time_zone(TestResult.first.sample_collected_at, :full_time),
          Extras::Dates::Format.datetime_with_time_zone(TestResult.first.result_at, :full_time),
          PatientResult.first.result_name,
          Devices::Presenter.device_name_and_serial_number(TestResult.first.device),
          Sites::Presenter.site_name(TestResult.first.site),
          SampleIdentifiers::Presenter.orphan_sample_id(TestResult.first),
          I18n.t('select.test_results.result_status.' + TestResult.first.result_status),
          PatientResult.first.result_type
        ]
      )
    end
  end
end
