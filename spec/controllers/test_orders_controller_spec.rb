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
      context 'format html' do
        it 'should display the right template' do
          get :index

          expect(response).to render_template('index')
        end
      end

      context 'format csv' do
        before :each do
          get :index, format: :csv
        end

        it 'should be a csv response' do
          expect(response.header["Content-Type"]).to eq('text/csv')
        end

        it 'should return data as csv' do
          expect(response.header["Content-Type"]).to eq('text/csv')
        end
      end
    end
  end
end
