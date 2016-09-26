require 'spec_helper'
require 'policy_spec_helper'

describe XpertResultsController do
  render_views
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:patient)        { Patient.make institution: institution }
  let(:encounter)      { Encounter.make institution: institution , user: user, patient: patient, test_batch: TestBatch.make(institution: institution) }
  let(:default_params) { { context: institution.uuid } }
  let!(:xpert_result)   { XpertResult.make test_batch: encounter.test_batch }
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

    describe 'show' do
      it 'should render the new template' do
        get 'show', test_batch_id: encounter.test_batch.id, id: xpert_result

        expect(request).to render_template('show')
      end
    end

    describe 'edit' do
      before :each do
        get 'edit', test_batch_id: encounter.test_batch.id, id: xpert_result
      end

      it 'should render the edit template' do
        expect(request).to render_template('edit')
      end
    end

    describe 'update' do
      context 'with valid data' do
        before :each do
          valid_params.merge!({ tuberculosis: 'not_detected' })
          put :update, test_batch_id: encounter.test_batch.id, id: xpert_result, xpert_result: valid_params
          xpert_result.reload
        end

        it 'should update the content' do
          expect(xpert_result.tuberculosis).to eq('not_detected')
        end

        it 'should redirect to the test order page' do
          expect(response).to redirect_to encounter_path(encounter.test_batch.encounter)
        end
      end

      context 'with invalid data' do
        before :each do
          valid_params.merge!({ tuberculosis: '' })
          put :update, test_batch_id: encounter.test_batch.id, id: xpert_result, xpert_result: valid_params
        end

        it 'should redirect to the test order page' do
          expect(request).to render_template('edit')
        end
      end
    end
  end
end
