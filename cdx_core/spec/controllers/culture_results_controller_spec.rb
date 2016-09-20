require 'spec_helper'
require 'policy_spec_helper'

describe CultureResultsController do
  render_views
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: user, patient: patient, test_batch: TestBatch.make(institution: institution) }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1) { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2) { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }
  let!(:culture_result)     { CultureResult.make test_batch: encounter.test_batch }
  let(:default_params)      { { context: institution.uuid } }
  let(:valid_params) do
    {
      sample_collected_on:    4.days.ago,
      media_used:             'solid',
      method_used:            'direct',
      serial_number:          'LO-3434-P',
      test_result:            'contaminated',
      examined_by:            'Michael Kiske',
      result_on:              1.day.ago
    }
  end

  context 'user with test orders permission' do
    before(:each) do
      sign_in user
    end

    describe 'show' do
      it 'should render the show template' do
        get 'show', test_batch_id: encounter.test_batch.id, id: culture_result

        expect(request).to render_template('show')
      end
    end

    describe 'edit' do
      before :each do
        get 'edit', test_batch_id: encounter.test_batch.id, id: culture_result
      end

      it 'should render the edit template' do
        expect(request).to render_template('edit')
      end
    end

    describe 'update' do
      context 'with valid data' do
        before :each do
          valid_params.merge!({ media_used: 'liquid' })
          put :update, test_batch_id: encounter.test_batch.id, id: culture_result, culture_result: valid_params
          culture_result.reload
        end

        it 'should update the content' do
          expect(culture_result.media_used).to eq('liquid')
        end

        it 'should redirect to the test order page' do
          expect(response).to redirect_to encounter_path(encounter.test_batch.encounter)
        end
      end

      context 'with invalid data' do
        before :each do
          valid_params.merge!({ media_used: '' })
          put :update, test_batch_id: encounter.test_batch.id, id: culture_result, culture_result: valid_params
        end

        it 'should redirect to the test order page' do
          expect(request).to render_template('edit')
        end
      end
    end
  end
end
