require 'spec_helper'

describe PatientResultsController do
  let(:user)              { User.make }
  let(:institution)       { user.institutions.make }
  let(:site) { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution, site: site }
  let(:encounter)         { Encounter.make institution: institution, patient: patient }
  let(:microscopy_result) { MicroscopyResult.make encounter: encounter }
  let(:feedback_message)  { FeedbackMessage.make(institution: institution) }
  let(:default_params)    { { context: institution.uuid } }
  let(:samples_ids)       { { microscopy_result.id.to_s => 'sample-id' } }

  before(:each) do
    sign_in user
  end

  describe 'update' do
    context 'update all' do
      let(:patient_result) { { result_status: 'completed', comment: 'New comment added', feedback_message_id: feedback_message.id } }

      before :each do
        put :update, encounter_id: encounter.id, id: microscopy_result.id, patient_result: patient_result, format: :json
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

    context 'update comment' do
      let(:patient_result) { { comment: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor' } }

      before :each do
        put :update, encounter_id: encounter.id, id: microscopy_result.id, patient_result: patient_result, format: :json
        microscopy_result.reload
      end

      it 'should update the status of the result' do
        expect(microscopy_result.comment).to eq('Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor')
      end
    end
  end
end
