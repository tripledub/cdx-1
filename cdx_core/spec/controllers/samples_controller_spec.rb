require 'spec_helper'

describe SamplesController do
  let!(:institution)      { Institution.make }
  let!(:user)             { institution.user }
  let(:patient)           { Patient.make institution: institution }
  let(:encounter)         { Encounter.make institution: institution, patient: patient }
  let(:default_params)    { { context: institution.uuid } }
  let(:samples_ids)       { ['sample-id', 'FX-3333-0'] }

  before(:each) do
    sign_in user
  end

  describe 'create' do
    context 'valid request' do
      before :each do
        encounter.update_attribute(:status, 'financed')
        post :create, encounter_id: encounter.id, samples: samples_ids
      end

      it 'should update requested samples' do
        expect(encounter.samples.count).to eq(2)
      end

      it 'should redirect to encounter view' do
        expect(response.status).to eq(200)
      end
    end

    context 'invalid request' do
      before :each do
        post :create, encounter_id: encounter.id, samples: samples_ids
      end

      it 'should redirect if test order has not been financed' do
        expect(response.status).to eq(422)
      end

      it 'should display an error message' do
        expect(JSON.parse(response.body)['result']).to eq(I18n.t('patient_results.update_samples.updated_fail'))
      end
    end
  end
end
