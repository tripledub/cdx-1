require 'spec_helper'

describe PatientResults::StatusAuditor do
  let(:user)           { User.make }
  let(:encounter)      { Encounter.make }
  let(:patient_result) { MicroscopyResult.make encounter: encounter, serial_number: 'FT43242-V' }

  before :each do
    User.current = user
  end

  describe 'create_status_log' do
    context 'when there is a serial number' do
      before :each do
        described_class.create_status_log(patient_result, %w(old_status new_status))
      end

      it 'should add a new log for the encounter with serial number' do
        expect(AuditLog.first.title).to eq("t{patient_results.update.status_tracking}: #{patient_result.serial_number}")
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

    context 'if there is no serial number' do
      before :each do
        patient_result.update_attribute(:serial_number, '')
        described_class.create_status_log(patient_result, %w(old_status new_status))
      end

      it 'should add a new log for the encounter with batch id' do
        expect(AuditLog.first.title).to eq("t{patient_results.update.status_tracking}: #{patient_result.encounter.batch_id}")
      end
    end
  end
end
