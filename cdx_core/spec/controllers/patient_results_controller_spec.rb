require 'spec_helper'

describe PatientResultsController do
  let(:user)              { User.make }
  let(:institution)       { user.institutions.make }
  let(:test_batch)        { TestBatch.make institution: institution }
  let(:microscopy_result) { MicroscopyResult.make test_batch: test_batch }
  let(:default_params)    { { context: institution.uuid } }
  let(:samples_ids)       { [
    { 'id' => microscopy_result.id, sample: 'sample-id' }
  ] }

  before(:each) do
    sign_in user

    put :update_samples, test_batch_id: test_batch.id, samples: samples_ids, format: :json
  end

  describe 'update_samples' do
    it 'should update requested samples' do
      microscopy_result.reload

      expect(microscopy_result.serial_number).to eq('sample-id')
    end

    it 'should return success' do
      expect(response.status).to eq(200)
    end
  end
end
