require 'spec_helper'
require 'policy_spec_helper'

describe PatientTestOrdersController do
  render_views
  let(:user)           { User.make }
  let(:institution)    { user.institutions.make }
  let(:site)           { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution }
  let(:device)         { Device.make  institution: institution, site: site }
  let(:default_params) { { context: institution.uuid } }

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
  end
end
