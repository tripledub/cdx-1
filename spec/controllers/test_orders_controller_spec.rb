require 'spec_helper'
require 'policy_spec_helper'

describe TestOrdersController, elasticsearch: true do
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:site)           { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution }
  let(:encounters)     { 7.times { Encounter.make institution: institution, site: site, patient: patient, start_time: 3.days.ago.to_s, testdue_date: 1.day.from_now.to_s, status: rand(0..2) } }
  let(:default_params) { { context: institution.uuid } }

  context 'a logged in user' do
    before(:each) do
      sign_in user
    end

    describe 'index' do
      it 'should display the right template' do
        get :index

        expect(response).to render_template('index')
      end
    end
  end
end
