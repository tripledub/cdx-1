require 'spec_helper'

describe Presenters::PatientTestResults do
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:site)           { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution }
  let(:device)         { Device.make  institution: institution, site: site }

  describe 'patient_view' do
    before :each do
      7.times { TestResult.make patient: patient, institution: institution, device: device  }
    end

    it 'should return an array of formated comments' do
      expect(Presenters::PatientTestResults.patient_view(patient.test_results).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(Presenters::PatientTestResults.patient_view(patient.test_results).first).to eq({
        id:              patient.test_results.first.uuid,
        name:            patient.test_results.first.core_fields[TestResult::NAME_FIELD],
        date:            Extras::Dates::Format.datetime_with_time_zone(patient.test_results.first.core_fields[TestResult::START_TIME_FIELD]),
        status:          patient.test_results.first.core_fields[TestResult::STATUS_FIELD],
        viewLink:        Rails.application.routes.url_helpers.test_result_path(id: patient.test_results.first.uuid)
      })
    end
  end
end
