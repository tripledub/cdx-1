require 'spec_helper'

RSpec.describe Patient, type: :model do
  let(:patient) { Patient.make }

  describe '#social_security_code' do
    context 'should be validated' do
      it 'is a string between 9 and 15 chars' do
        patient.social_security_code = SecureRandom.hex(6)
        expect(patient).to be_valid
      end

      it 'is a string with less than 9 characters' do
        patient.social_security_code = SecureRandom.hex(3)
        expect(patient).to be_invalid
      end

      it 'is a string with less more than 15 characters' do
        patient.social_security_code = SecureRandom.hex(16)
        expect(patient).to be_invalid
      end

      it 'is nil' do
        patient.social_security_code = nil
        expect(patient).to be_valid
      end

      it 'is blank' do
        patient.social_security_code = ''
        expect(patient).to be_valid
      end
    end

    context 'should not be validated' do
      before :each do
        patient.skip_ssc_validation = true
      end

      it 'is a string between 9 and 15 chars' do
        patient.social_security_code = SecureRandom.hex(6)
        expect(patient).to be_valid
      end

      it 'is a string with less than 9 characters' do
        patient.social_security_code = SecureRandom.hex(3)
        expect(patient).to be_valid
      end

      it 'is a string with less more than 15 characters' do
        patient.social_security_code = SecureRandom.hex(16)
        expect(patient).to be_valid
      end
    end
  end

  describe '#vitimes_id' do
    context 'is added to #custom_fields' do
      let(:patient) { Patient.make(vitimes_id: '12345') }
      before { patient.reload }
      it { expect(patient.custom_fields['vitimes_id']).to eq('12345') }
    end

    context 'is removed from #custom_fields' do
      let(:patient) { Patient.make(vitimes_id: '12345') }
      before {
        patient.reload
        patient.vitimes_id = nil
        patient.save
        patient.reload
      }
      it { expect(patient.custom_fields['vitimes_id']).to eq(nil) }
    end
  end
end
