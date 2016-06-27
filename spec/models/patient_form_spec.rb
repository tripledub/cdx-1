require 'spec_helper'

describe PatientForm do
  let(:user)    { User.make }
  let(:patient) { Patient.make name: 'Ruben Barichello'}

  describe 'An auditable model' do
    it 'should log the changes' do
      patient_form = PatientForm.edit(patient)
      old_name     = patient_form.name
      patient_form.name = 'new name'
      patient_form.save_and_audit(user, 'Updating patient')
      audit_update = patient.audit_logs.last.audit_updates.first

      expect(audit_update.field_name).to eq('name')
      expect(audit_update.old_value).to eq(old_name)
      expect(audit_update.new_value).to eq('new name')
    end
  end
end
