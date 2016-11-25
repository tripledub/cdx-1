require 'spec_helper'

describe PatientLogs::Presenter do
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:device)         { Device.make institution: institution }
  let(:patient)        { Patient.make institution: institution }

  describe 'patient_view' do
    before :each do
      7.times { AuditLog.make patient: patient, user: user, device: device }
      @logs = patient.audit_logs.page
    end

    it 'should return an array of formated comments' do
      expect(described_class.patient_view(@logs, '')['rows'].size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.patient_view(@logs, '')['rows'].first).to eq({
        id:       patient.audit_logs.first.uuid,
        date:     I18n.l(patient.audit_logs.first.created_at, format: :short),
        user:     patient.audit_logs.first.user.full_name,
        device:   patient.audit_logs.first.device.full_name,
        title:    patient.audit_logs.first.title,
        viewLink: Rails.application.routes.url_helpers.patient_patient_log_path(patient.audit_logs.first.patient, patient.audit_logs.first)
      })
    end

    it 'includes pagination data' do
      expect(described_class.patient_view(@logs, '')['pages']).to eq(
        currentPage: 1,
        firstPage: true,
        lastPage: true,
        nextPage: nil,
        prevPage: nil,
        totalPages: 1
      )
    end
  end
end
