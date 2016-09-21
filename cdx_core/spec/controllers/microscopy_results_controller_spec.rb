require 'spec_helper'
require 'policy_spec_helper'

describe MicroscopyResultsController do
  render_views
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: user, patient: patient }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1) { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2) { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }
  let(:requested_test)      { RequestedTest.make encounter: encounter }
  let(:microscopy_result)   { MicroscopyResult.make requested_test: requested_test }
  let(:default_params) { { context: institution.uuid } }
  let(:valid_params)   { {
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

    describe 'new' do
      before :each do
        get 'new', requested_test_id: requested_test.id
      end

      it 'should render the new template' do
        expect(request).to render_template('new')
      end

      it 'should add test order samples id to laboratory serial numbers' do
        expect(assigns(:microscopy_result).serial_number).to eq("#{sample_identifier1.entity_id}, #{sample_identifier2.entity_id}")
      end
    end

    describe 'create' do
      context 'with valid params' do
        before :each do
          post :create, requested_test_id: requested_test.id, microscopy_result: valid_params
          requested_test.reload
        end

        it 'should save the comment' do
          patient_result = requested_test.microscopy_result

          expect(patient_result.specimen_type).to eq('blood')
          expect(patient_result.uuid).not_to be_empty
          expect(patient_result.serial_number).to eq('LO-3434-P')
          expect(patient_result.appearance).to eq('saliva')
          expect(patient_result.test_result).to eq('3plus')
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
          post :create, requested_test_id: requested_test.id, microscopy_result: invalid_params

          expect(request).to render_template('new')
        end
      end
     end

    describe 'show' do
      it 'should render the new template' do
        microscopy_result
        get 'show', requested_test_id: requested_test.id

        expect(request).to render_template('show')
      end
    end

    describe 'update' do
      context 'with valid data' do
        before :each do
          microscopy_result
          valid_params.merge!({ appearance: 'blood' })
          put :update, requested_test_id: requested_test.id, microscopy_result: valid_params
        end

        it 'should update the content' do
          expect(requested_test.microscopy_result.appearance).to eq('blood')
        end

        it 'should redirect to the test order page' do
          expect(response).to redirect_to encounter_path(requested_test.encounter)
        end
      end

      context 'with invalid data' do
        before :each do
          microscopy_result
          valid_params.merge!({ appearance: '' })
          put :update, requested_test_id: requested_test.id, microscopy_result: valid_params
        end

        it 'should redirect to the test order page' do
          expect(request).to render_template('edit')
        end
      end
    end
  end
end
