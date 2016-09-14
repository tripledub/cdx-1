require 'spec_helper'

describe Presenters::PatientTestOrders do
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:site)           { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution }
  let(:device)         { Device.make  institution: institution, site: site }

  describe 'patient_view' do
    before :each do
      7.times { Encounter.make institution: institution, site: site, patient: patient, start_time: 3.days.ago.to_s, status: 1  }
    end

    it 'should return an array of formated comments' do
      expect(described_class.patient_view(patient.encounters).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.patient_view(patient.encounters).first).to eq({
        id:          patient.encounters.first.uuid,
        batchId:     patient.encounters.first.batch_id,
        siteName:    patient.encounters.first.site.name,
        performingSiteName:  patient.encounters.first.site.name,
        requester:   patient.encounters.first.user.full_name,
        requestDate: I18n.l(Time.parse(patient.encounters.first.start_time), format: :long),
        dueDate:     nil,
        status:      'In progress',
        statusRaw:   'inprogress',
        viewLink:    Rails.application.routes.url_helpers.encounter_path(patient.encounters.first)
      })
    end
  end
end
