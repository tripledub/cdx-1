require 'spec_helper'

describe PatientResults::StatusAuditor do
  let(:user)           { User.make }
  let(:encounter)      { Encounter.make }
  let(:patient_result) { MicroscopyResult.make encounter: encounter }

  describe 'create_status_log' do
    before :each do
      User.current = user
      described_class.create_status_log(patient_result, %w(old_status new_status))
    end

    it 'should add a new log for the encounter' do
      expect(AuditLog.first.title).to eq('t{patient_results.update.status_tracking}')
    end

    it 'should assign the log to the encounter' do
      expect(AuditLog.first.patient_result).to eq(patient_result)
    end

    it 'should save the old status' do
      expect(AuditLog.first.audit_updates.first.old_value).to eq('old_status')
    end

    it 'should save the new status' do
      expect(AuditLog.first.audit_updates.first.new_value).to eq('new_status')
    end
  end
end
