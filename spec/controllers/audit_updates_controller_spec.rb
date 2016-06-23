require 'spec_helper'
require 'policy_spec_helper'

describe AuditUpdatesController do
  render_views
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:patient)        { Patient.make institution: institution }
  let(:default_params) { { context: institution.uuid } }
  let(:audit_log)      { AuditLog.make patient: patient, user: user }

  context 'logged in user' do
    before(:each) do
      sign_in user
      8.times { AuditUpdate.make audit_log: audit_log }
    end

    describe 'index' do
      it 'should return a json with comments' do
        get 'index', patient_id: patient.id, patient_log_id: audit_log

        expect(JSON.parse(response.body).size).to eq(8)
      end
    end
  end
end
