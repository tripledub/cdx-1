require 'spec_helper'
require 'policy_spec_helper'

describe CultureResultsController do
  render_views
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let!(:site) { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution, site: site }
  let(:encounter)           { Encounter.make institution: institution , user: user, patient: patient }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1) { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2) { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }
  let!(:culture_result)     { CultureResult.make encounter: encounter, sample_identifier: sample_identifier1 }
  let(:default_params)      { { context: institution.uuid } }
  let(:valid_params) do
    {
      sample_collected_at:    4.days.ago,
      media_used:             'solid',
      method_used:            'direct',
      serial_number:          'LO-3434-P',
      test_result:            'contaminated',
      examined_by:            'Michael Kiske',
      result_at:              1.day.ago,
      comment:                'Keeper of the seven keys'
    }
  end

  context 'user with test orders permission' do
    before(:each) do
      sign_in user
    end

    describe 'show' do
      it 'should render the show template' do
        get 'show', encounter_id: encounter.id, id: culture_result

        expect(request).to render_template('show')
      end
    end

    describe 'edit' do
      before :each do
        get 'edit', encounter_id: encounter.id, id: culture_result
      end

      it 'should render the edit template' do
        expect(request).to render_template('edit')
      end
    end

    describe 'update' do
      context 'with valid data' do
        before :each do
          valid_params.merge!({ media_used: 'liquid' })
          put :update, encounter_id: encounter.id, id: culture_result, culture_result: valid_params
          culture_result.reload
        end

        it 'should update the content' do
          expect(culture_result.media_used).to eq('liquid')
        end

        it 'should redirect to the test order page' do
          expect(response).to redirect_to encounter_path(encounter)
        end
      end

      context 'with invalid data' do
        before :each do
          valid_params.merge!({ media_used: '' })
          put :update, encounter_id: encounter.id, id: culture_result, culture_result: valid_params
        end

        it 'should redirect to the test order page' do
          expect(request).to render_template('edit')
        end
      end
    end
  end
end
