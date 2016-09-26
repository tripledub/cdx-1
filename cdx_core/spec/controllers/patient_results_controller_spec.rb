require 'spec_helper'

describe PatientResultsController do
  let(:user)              { User.make }
  let(:institution)       { user.institutions.make }
  let(:patient)           { Patient.make institution: institution }
  let(:encounter)         { Encounter.make institution: institution, patient: patient }
  let(:test_batch)        { TestBatch.make encounter: encounter, institution: institution }
  let(:microscopy_result) { MicroscopyResult.make test_batch: test_batch }
  let(:feedback_message)  { FeedbackMessage.make(institution: institution) }
  let(:default_params)    { { context: institution.uuid } }
  let(:samples_ids)       {
    { microscopy_result.id.to_s => 'sample-id' }
  }

  before(:each) do
    sign_in user
  end

  describe 'update_samples' do
    before :each do
      post :update_samples, test_batch_id: test_batch.id, samples: samples_ids
    end

    it 'should update requested samples' do
      microscopy_result.reload

      expect(microscopy_result.serial_number).to eq('sample-id')
    end

    it 'should redirect to encounter view' do
      expect(response).to redirect_to(encounter_path(encounter))
    end
  end

  describe 'update' do
    let(:patient_result) { { result_status: 'completed', comment: 'New comment added', feedback_message_id: feedback_message.id } }

    before :each do
      put :update, test_batch_id: test_batch.id, id: microscopy_result.id, patient_result: patient_result, format: :json
      microscopy_result.reload
    end

    it 'should update the status of the result' do
      expect(microscopy_result.result_status).to eq('completed')
    end

    it 'should update the comment' do
      expect(microscopy_result.comment).to eq('New comment added')
    end

    it 'should update the feedback message' do
      expect(microscopy_result.feedback_message).to eq(feedback_message)
    end
  end
end
