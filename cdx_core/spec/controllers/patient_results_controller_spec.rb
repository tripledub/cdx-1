require 'spec_helper'

describe PatientResultsController do
  let(:user)              { User.make }
  let(:institution)       { user.institutions.make }
  let(:patient)           { Patient.make institution: institution }
  let(:encounter)         { Encounter.make institution: institution, patient: patient }
  let(:test_batch)        { TestBatch.make encounter: encounter, institution: institution }
  let(:microscopy_result) { MicroscopyResult.make test_batch: test_batch }
  let(:default_params)    { { context: institution.uuid } }
  let(:samples_ids)       {
    { microscopy_result.id.to_s => 'sample-id' }
  }

  before(:each) do
    sign_in user

    post :update_samples, test_batch_id: test_batch.id, samples: samples_ids
  end

  describe 'update_samples' do
    it 'should update requested samples' do
      microscopy_result.reload

      expect(microscopy_result.serial_number).to eq('sample-id')
    end

    it 'should redirect to encounter view' do
      expect(response).to redirect_to(encounter_path(encounter))
    end
  end
end
