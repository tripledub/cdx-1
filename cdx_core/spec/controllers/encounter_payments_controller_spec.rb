require 'spec_helper'

describe EncounterPaymentsController do
  let(:user)              { User.make }
  let(:institution)       { user.institutions.make }
  let(:patient)           { Patient.make institution: institution }
  let(:encounter)         { Encounter.make institution: institution, patient: patient }
  let(:default_params)    { { context: institution.uuid } }

  before(:each) do
    sign_in user
  end

  describe 'set_as_paid' do
    it 'should be pending as default' do
      expect(encounter.payment_done).to eq false
    end

    it 'should update payment status as done' do
      post :set_as_paid, encounter_id: encounter.id
      encounter.reload

      expect(encounter.payment_done).to eq true
    end
  end
end
