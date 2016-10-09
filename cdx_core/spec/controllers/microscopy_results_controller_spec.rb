require 'spec_helper'
require 'policy_spec_helper'

describe MicroscopyResultsController do
  render_views
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution, user: user, patient: patient }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1) { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2) { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }
  let(:microscopy_result)   { MicroscopyResult.make encounter: encounter, sample_identifier: sample_identifier1 }
  let(:default_params)      { { context: institution.uuid } }
  let(:valid_params)        { {
    sample_collected_on: 4.days.ago,
    specimen_type:       'blood',
    serial_number:       'LO-3434-P',
    appearance:          'saliva',
    test_result:         '3plus',
    examined_by:         'Michael Kiske',
    result_on:           1.day.ago
  } }

  context 'user with test orders permission' do
    before(:each) do
      sign_in user
    end

    describe 'show' do
      it 'should render the new template' do
        microscopy_result
        get 'show', encounter_id: encounter.id, id: microscopy_result

        expect(request).to render_template('show')
      end
    end

    describe 'update' do
      context 'with valid data' do
        before :each do
          microscopy_result
          valid_params[:appearance] = 'blood'
          put :update, encounter_id: encounter.id, id: microscopy_result, microscopy_result: valid_params
        end

        it 'should update the content' do
          expect(microscopy_result.appearance).to eq('blood')
        end

        it 'should redirect to the test order page' do
          expect(response).to redirect_to encounter_path(encounter)
        end
      end

      context 'with invalid data' do
        before :each do
          microscopy_result
          valid_params[:appearance] = ''
          put :update, encounter_id: encounter.id, id: microscopy_result, microscopy_result: valid_params
        end

        it 'should redirect to the test order page' do
          expect(request).to render_template('edit')
        end
      end
    end
  end
end
