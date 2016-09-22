require 'spec_helper'

RSpec.describe Patient, type: :model do

  describe '#social_security_code' do

    context 'is \'1234567890\'' do
      let(:patient) { Patient.make }

      it { expect(patient).to be_valid }
    end

    context 'is \'1234\'' do
      let(:patient) { Patient.make }

      it do
        patient.social_security_code = 1234
        expect(patient).to be_invalid
      end
    end
  end
end