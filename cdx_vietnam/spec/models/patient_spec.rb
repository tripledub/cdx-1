require 'spec_helper'

RSpec.describe Patient, type: :model do

  describe '#social_security_code' do

    context 'is a 10 character string' do
      let(:patient) { Patient.make }

      it { expect(patient).to be_valid }
    end

    context 'is a 4 character string' do
      let(:patient) { Patient.make }

      it do
        patient.social_security_code = 1234
        expect(patient).to be_invalid
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
