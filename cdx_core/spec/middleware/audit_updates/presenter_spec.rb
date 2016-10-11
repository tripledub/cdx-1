require 'spec_helper'

describe AuditUpdates::Presenter do
  let(:audit_log) { AuditLog.make }

  describe 'patient_view' do
    before :each do
      27.times { AuditUpdate.make audit_log: audit_log }
    end

    it 'should return an array of formated comments' do
      expect(described_class.patient_view(audit_log.audit_updates).size).to eq(27)
    end

    it 'should return elements formated' do
      expect(described_class.patient_view(audit_log.audit_updates).first).to eq({
        id:        audit_log.audit_updates.first.id,
        fieldName: audit_log.audit_updates.first.field_name,
        oldValue:  audit_log.audit_updates.first.old_value,
        newValue:  audit_log.audit_updates.first.new_value
      })
    end
  end
end
