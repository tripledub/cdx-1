require 'spec_helper'

describe Audit::Auditor do
  let(:user)     { User.make }
  let(:address1) { Address.make }
  let(:address2) { Address.make address: '22 Acacia Avenue' }
  let(:patient)  { Patient.make name: 'Ruben Barichello', addresses: [address1, address2] }

  describe 'create' do
    before :each do
      described_class.new(patient, user.id).log_action("New patient #{patient.name} added")
    end

    it 'should add a new audit log' do
      expect { described_class.new(patient, user.id).log_action("New patient #{patient.name} added") }.to change { AuditLog.count }.by(1)
    end

    it 'should add a title' do
      expect(AuditLog.first.title).to eq("New patient #{patient.name} added")
    end

    it 'should add a patient' do
      expect(AuditLog.first.patient).to eq(patient)
    end

    it 'should add an user' do
      expect(AuditLog.first.user).to eq(user)
    end

    context 'when language translations are present' do
      before :each do
        described_class.new(patient, user.id).log_action("t{patients.show.new_episode} #{patient.name} added")
      end

      it 'should return the translated version of the string' do
        expect(AuditLog.last.title).to include("#{patient.name} added")
      end
    end
  end

  describe 'update' do
    before :each do
      patient.name                    = 'Graham Hill'
      patient.addresses.first.address = '1428 Elm Street'
      described_class.new(patient, user.id).log_changes("#{patient.name} patient details have been updated")
    end

    it 'should add a new audit log' do
      expect {
        described_class.new(patient, user.id).log_changes("#{patient.name} patient details have been updated")
      }.to change { AuditLog.count }.by(1)
    end

    it 'should add a title' do
      expect(AuditLog.first.title).to eq("#{patient.name} patient details have been updated")
    end

    it 'should add a patient' do
      expect(AuditLog.first.patient).to eq(patient)
    end

    it 'should add an user' do
      expect(AuditLog.first.user).to eq(user)
    end

    context 'with updated values' do
      subject { AuditLog.first.audit_updates.where(field_name: 'name').first }

      it 'should log the name change' do
        expect(subject).to be
      end

      it 'should log the name old value' do
        expect(subject.old_value).to eq('Ruben Barichello')
      end

      it 'should log the name new value' do
        expect(subject.new_value).to eq('Graham Hill')
      end
    end
  end
end
