require 'spec_helper'

describe Presenters::PatientTestOrders do
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:site)           { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution }
  let(:device)         { Device.make  institution: institution, site: site }

  describe 'patient_view' do
    before :each do
      7.times { Encounter.make institution: institution, site: site, patient: patient  }
    end

    it 'should return an array of formated comments' do
      expect(Presenters::PatientTestOrders.patient_view(patient.encounters).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(Presenters::PatientTestOrders.patient_view(patient.encounters).first).to eq({
        id:          patient.encounters.first.uuid,
        siteName:    patient.encounters.first.site.name,
        requester:   patient.encounters.first.user.full_name,
        requestDate: Extras::Dates::Format.datetime_with_time_zone(patient.encounters.first.start_time),
        dueDate:     Extras::Dates::Format.datetime_with_time_zone(patient.encounters.first.testdue_date),
        status:      patient.encounters.first.core_fields['status'],
        viewLink:    Rails.application.routes.url_helpers.encounter_path(patient.encounters.first)
      })
    end
  end
end
