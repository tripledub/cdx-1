require 'spec_helper'
require 'policy_spec_helper'

describe TestOrdersController, elasticsearch: true do
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let(:site)           { Site.make institution: institution }
  let(:site2)          { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution }
  let!(:encounters)    {
    7.times {
      encounter = Encounter.make institution: institution, site: site, patient: patient, start_time: 3.days.ago.strftime("%Y-%m-%d"), testdue_date: 1.day.from_now.strftime("%Y-%m-%d"), status: rand(0..2)
      EncounterIndexer.new(encounter).index(true)
    }
    encounter = Encounter.make institution: institution, site: site, performing_site_id: site2.id, patient: patient, start_time: 3.days.ago.strftime("%Y-%m-%d"), testdue_date: 1.day.from_now.strftime("%Y-%m-%d"), status: rand(0..2)
    EncounterIndexer.new(encounter).index(true)
  }
  let(:default_params) { { context: site.uuid } }

  context 'a logged in user' do
    before(:each) do
      sign_in user
    end

    describe 'index' do
      context 'format html' do
        context 'when context is site' do
          before :each do
            default_params
            get :index
          end

          it 'should display the right template' do
            expect(response).to render_template('index')
          end

          it 'should display the test orders' do
            expect(assigns(:total)).to eq(8)
          end
        end

        context 'when context is site2' do
          let(:default_params) { { context: site2.uuid } }

          before :each do
            default_params
            get :index
          end

          it 'should display the right template' do
            expect(response).to render_template('index')
          end

          it 'should display the test orders this site is performing' do
            expect(assigns(:total)).to eq(1)
          end
        end
      end

      context 'format csv' do
        before :each do
          get :index, format: :csv
        end

        it 'should be a csv response' do
          expect(response.header["Content-Type"]).to eq('text/csv')
        end
      end
    end
  end
end
