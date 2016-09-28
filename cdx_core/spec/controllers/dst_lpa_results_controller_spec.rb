require 'spec_helper'
require 'policy_spec_helper'

describe DstLpaResultsController do
  render_views
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: user, patient: patient }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1) { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2) { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }
  let!(:dst_lpa_result)      { DstLpaResult.make encounter: encounter }
  let(:default_params)      { { context: institution.uuid } }
  let(:valid_params)        { {
    sample_collected_on: 4.days.ago,
    media_used:          'solid',
    method_used:         'direct',
    serial_number:       'LO-3434-P',
    results_h:           'resistant',
    results_r:           'susceptible',
    results_e:           'contaminated',
    results_s:           'not_done',
    results_amk:         'not_done',
    results_km:          'susceptible',
    results_cm:          'resistant',
    results_fq:          'contaminated',
    results_other1:      'other 1',
    results_other2:      'other 2',
    results_other3:      'other 3',
    results_other4:      'other 4',
    examined_by:         'Michael Kiske',
    result_on:           1.day.ago
  } }

  context 'user with test orders permission' do
    before(:each) do
      sign_in user
    end

    describe 'show' do
      it 'should render the new template' do
        get 'show', encounter_id: encounter.id, id: dst_lpa_result

        expect(request).to render_template('show')
      end
    end

    describe 'update' do
      context 'with valid data' do
        before :each do
          valid_params.merge!({ media_used: 'liquid' })
          put :update, encounter_id: encounter.id, id: dst_lpa_result, dst_lpa_result: valid_params
          dst_lpa_result.reload
        end

        it 'should update the content' do
          expect(dst_lpa_result.media_used).to eq('liquid')
        end

        it 'should redirect to the test order page' do
          expect(response).to redirect_to encounter_path(encounter)
        end
      end

      context 'with invalid data' do
        before :each do
          valid_params.merge!({ media_used: '' })
          put :update, encounter_id: encounter.id, id: dst_lpa_result, dst_lpa_result: valid_params
        end

        it 'should redirect to the test order page' do
          expect(request).to render_template('edit')
        end
      end
    end
  end
end
