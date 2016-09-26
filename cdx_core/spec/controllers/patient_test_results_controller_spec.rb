require 'spec_helper'
require 'policy_spec_helper'

describe PatientTestResultsController do
  render_views
  let(:user)           { User.make }
  let(:institution)    { user.institutions.make }
  let(:site)           { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution }
  let(:encounter)      { Encounter.make institution: institution , user: user, patient: patient, test_batch: TestBatch.make(institution: institution) }
  let(:device)         { Device.make  institution: institution, site: site }
  let(:default_params) { { context: institution.uuid } }

  context 'logged in user' do
    before(:each) do
      sign_in user
    end

    describe 'index' do
      before :each do
        4.times do
          TestResult.make patient: patient, institution: institution, device: device
        end
        2.times do
          MicroscopyResult.make test_batch: encounter.test_batch
        end
        2.times do
          CultureResult.make test_batch: encounter.test_batch
        end
        2.times do
          DstLpaResult.make test_batch: encounter.test_batch
        end
        XpertResult.make test_batch: encounter.test_batch
      end

      it 'should return a json with test results' do
        get 'index', patient_id: patient.id

        expect(JSON.parse(response.body).size).to eq(11)
      end
    end
  end
end
