require 'spec_helper'
require 'policy_spec_helper'

describe SampleIdentifiersController do
  render_views
  let(:user)              { User.make }
  let!(:institution)      { user.institutions.make }
  let!(:site) { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution, site: site }
  let(:encounter)         { Encounter.make institution: institution , user: user, patient: patient }
  let(:sample_identifier) { SampleIdentifier.make(site: site, entity_id: "entity random", cpd_id_sample: 'Random lab sample', sample: Sample.make(institution: institution, encounter: encounter, patient: patient)) }
  let(:valid_params)      { { cpd_id_sample: 'Some text' } }
  let(:default_params)    { { context: institution.uuid } }

  describe 'logged in user' do
    before :each do
      sign_in user
    end

    describe 'update' do
      it 'should update the sample' do
        put :update, id: sample_identifier.uuid, sample_identifier: valid_params, format: :json
        sample_identifier.reload

        expect(sample_identifier.cpd_id_sample).to eq('Some text')
      end
    end
  end
end
