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
end
