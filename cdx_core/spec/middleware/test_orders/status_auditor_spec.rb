require 'spec_helper'

describe TestOrders::StatusAuditor do
  let(:user) { User.make }
  let(:encounter) { Encounter.make }

  describe 'create_status_log' do
    before :each do
      User.current = user
      described_class.create_status_log(encounter, %w(old_status new_status))
    end

    it 'should add a new log for the encounter' do
      expect(AuditLog.first.title).to eq('t{encounters.update.status_tracking}')
    end

    it 'should assign the log to the encounter' do
      expect(AuditLog.first.encounter).to eq(encounter)
    end

    it 'should save the old status' do
      expect(AuditLog.first.audit_updates.first.old_value).to eq('old_status')
    end

    it 'should save the new status' do
      expect(AuditLog.first.audit_updates.first.new_value).to eq('new_status')
    end
  end
end
