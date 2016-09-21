require 'spec_helper'
require 'policy_spec_helper'

describe PatientLogsController do
  render_views
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:patient)        { Patient.make institution: institution }
  let(:default_params) { { context: institution.uuid } }

  context 'user with edit patient permission' do
    before(:each) do
      sign_in user
    end

    describe 'index' do
      before :each do
        9.times { AuditLog.make patient: patient, user: user }
      end

      it 'should return a json with comments' do
        get 'index', patient_id: patient.id

        expect(JSON.parse(response.body).size).to eq(9)
      end
    end

    describe 'show' do
      let(:audit_log) { AuditLog.make patient: patient, user: user }

      before :each do
        get 'show', patient_id: patient.id, id: audit_log.id
      end

      it 'should display the right template' do
        expect(response).to render_template('show')
      end
    end
  end
end
