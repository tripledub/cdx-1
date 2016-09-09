require 'spec_helper'
require 'policy_spec_helper'

describe XpertResultsController do
  render_views
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:patient)        { Patient.make institution: institution }
  let(:encounter)      { Encounter.make institution: institution , user: user, patient: patient }
  let(:requested_test) { RequestedTest.make encounter: encounter }
  let(:default_params) { { context: institution.uuid } }
  let(:xpert_result)   { XpertResult.make requested_test: requested_test }
  let(:valid_params)   { {
    sample_collected_on: 4.days.ago,
    tuberculosis:        'detected',
    rifampicin:          'not_detected',
    examined_by:         'Michael Kiske',
    result_on:           1.day.ago
  } }

  context 'user with test orders permission' do
    before(:each) do
      sign_in user
    end

    describe 'new' do
      it 'should render the new template' do
        get 'new', requested_test_id: requested_test.id

        expect(request).to render_template('new')
      end
    end

    describe 'create' do
      context 'with valid params' do
        before :each do
          post :create, requested_test_id: requested_test.id, xpert_result: valid_params
          requested_test.reload
        end

        it 'should save the comment' do
          patient_result = requested_test.xpert_result

          expect(patient_result.tuberculosis).to eq('detected')
          expect(patient_result.uuid).not_to be_empty
          expect(patient_result.rifampicin).to eq('not_detected')
          expect(patient_result.sample_collected_on.strftime("%m/%d/%YYYY")).to eq(4.days.ago.strftime("%m/%d/%YYYY"))
          expect(patient_result.result_on.strftime("%m/%d/%YYYY")).to eq(1.day.ago.strftime("%m/%d/%YYYY"))
        end

        it 'should redirect to the test order page' do
          expect(response).to redirect_to encounter_path(encounter)
        end

        it 'should update the test status to complete' do
          expect(requested_test.status).to eq('completed')
        end
      end

      context 'with invalid params' do
        it 'should render the new form' do
          invalid_params = valid_params.merge!(examined_by: nil)
          post :create, requested_test_id: requested_test.id, xpert_result: invalid_params

          expect(request).to render_template('new')
        end
      end
     end

    describe 'show' do
      it 'should render the new template' do
        xpert_result
        get 'show', requested_test_id: requested_test.id

        expect(request).to render_template('show')
      end
    end

    describe 'edit' do
      before :each do
        xpert_result
        get 'edit', requested_test_id: requested_test.id
      end

      it 'should render the edit template' do
        expect(request).to render_template('edit')
      end
    end

    describe 'update' do
      context 'with valid data' do
        before :each do
          xpert_result
          valid_params.merge!({ tuberculosis: 'not_detected' })
          put :update, requested_test_id: requested_test.id, xpert_result: valid_params
        end

        it 'should update the content' do
          expect(requested_test.xpert_result.tuberculosis).to eq('not_detected')
        end

        it 'should redirect to the test order page' do
          expect(response).to redirect_to encounter_path(requested_test.encounter)
        end
      end

      context 'with invalid data' do
        before :each do
          xpert_result
          valid_params.merge!({ tuberculosis: '' })
          put :update, requested_test_id: requested_test.id, xpert_result: valid_params
        end

        it 'should redirect to the test order page' do
          expect(request).to render_template('edit')
        end
      end
    end
  end
end
