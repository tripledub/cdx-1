require 'spec_helper'
require 'policy_spec_helper'

describe PatientTestOrdersController do
  render_views
  let(:user)             { User.make }
  let(:institution)      { user.institutions.make }
  let(:site)             { Site.make institution: institution }
  let(:patient)          { Patient.make institution: institution }
  let(:device)           { Device.make  institution: institution, site: site }
  let(:encounter)        { Encounter.make patient: patient, institution: institution }
  let(:default_params)   { { context: institution.uuid } }
  let(:feedback_message) { FeedbackMessage.make institution: institution }
  let(:update_params)    do
    {
      comment: 'New comment for the encounter',
      feedback_message_id: feedback_message.id,
      status: 'financed'
    }
  end

  context 'logged in user' do
    before(:each) do
      sign_in user
    end

    describe 'index' do
      before :each do
        11.times do
          Encounter.make institution: institution, site: site, patient: patient
        end
      end

      it 'should return a json with comments' do
        get 'index', patient_id: patient.id

        expect(JSON.parse(response.body).size).to eq(11)
      end
    end

    describe 'update' do
      context 'valid request' do
        before :each do
          put 'update', patient_id: patient.id, id: encounter.id, encounter: update_params
          encounter.reload
        end

        it 'should update the status' do
          expect(encounter.status).to eq('financed')
        end

        it 'should update the comment' do
          expect(encounter.comment).to eq('New comment for the encounter')
        end

        it 'should update the feedback message' do
          expect(encounter.feedback_message).to eq(feedback_message)
        end
      end
    end
  end
end
