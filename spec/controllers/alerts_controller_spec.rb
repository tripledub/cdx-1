require 'spec_helper'
require 'policy_spec_helper'

describe AlertsController, type: :controller, elasticsearch: true do
  render_views
  let!(:user)          { User.make }
  let!(:institution)   { user.create Institution.make_unsaved }
  let(:default_params) { { context: institution.uuid } }

  let(:user2)         { User.make }
  let(:root_location) { Location.make }
  let(:location)      { Location.make parent: root_location }
  let(:site)          { Site.make institution: institution, location: location }
  let(:site2)         { Site.make institution: institution, location: location }
  let(:subsite)       { Site.make institution: institution, location: location, parent: site }
  let(:device)        { Device.make institution_id: institution.id, site: site }
  let(:device2)       { Device.make institution_id: institution.id, site: site }
  let(:alert)         { Alert.make institution_id: institution.id }
  let(:role)          { Role.make institution_id: institution.id }
  let(:alert_params)  { {
    name:         'Updated alert',
    devices_info: "#{device2.id}, #{device.id}",
    sites_info:   "#{site2.id}, #{site.id}",
    condition_results_info: 'positive',
    roles: role.id,
    users_info: user2.id,
    external_users: {
      '0': { id: '12', first_name: 'External', last_name: 'User', email: 'external@user.com', telephone: '444' }
    },
    sample_id: '963'
  }}

  before :each do
    sign_in user
  end

  describe 'create' do
    context 'Test results' do
      let(:test_results_params) { alert_params.merge(name: 'New alert', institution_id: institution.id, category_type: 'test_results')}

      context 'with valid data' do
        before :each do
          post :create, alert: test_results_params
          @alert = Alert.where(name: 'New alert').first
        end

        it 'should create the name' do
          expect(@alert.name).to eq('New alert')
        end

        it 'should create the device' do
          expect(@alert.query['device.uuid']).to include(device2.uuid)
          expect(@alert.query['device.uuid']).to include(device.uuid)
        end

        it 'should create the institution' do
          expect(@alert.query['institution.uuid']).to eq(institution.uuid)
        end

        it 'should create a test of the specimen type' do
          expect(@alert.query['test.type']).to eq('specimen')
        end

        it 'should create the sites info' do
          expect(@alert.query['site.uuid']).to include(site.uuid)
        end

        it 'should create the results info' do
          expect(@alert.query['test.assays.result']).to include('positive')
        end

        it 'should create the sample id' do
          expect(@alert.query['sample.id']).to eq('963')
        end

        it 'should create the roles' do
          alert_recipient = @alert.alert_recipients.where(recipient_type: AlertRecipient.recipient_types['role']).first

          expect(alert_recipient.role.id).to eq(role.id)
        end

        it 'should create the internal alert recipients' do
          alert_recipient = @alert.alert_recipients.where(recipient_type: AlertRecipient.recipient_types['internal_user']).first

          expect(alert_recipient.user.id).to eq(user2.id)
        end

        it 'should create the external alert recipients' do
          alert_recipient = @alert.alert_recipients.where(recipient_type: AlertRecipient.recipient_types['external_user']).first

          expect(alert_recipient.email).to eq('external@user.com')
          expect(alert_recipient.telephone).to eq('444')
          expect(alert_recipient.first_name).to eq('External')
          expect(alert_recipient.last_name).to eq('User')
        end
      end
    end
  end

  describe 'update' do
    let(:test_results_params) { alert_params.merge(category_type: 'test_results')}

    before :each do
      post :update, id: alert.id, alert: test_results_params
      alert.reload
    end

    context 'Test results' do
      context 'with valid data' do
        it 'should update the name' do
          expect(alert.name).to eq('Updated alert')
        end

        it 'should update the device' do
          expect(alert.query['device.uuid']).to include(device2.uuid)
          expect(alert.query['device.uuid']).to include(device.uuid)
        end

        it 'should update the institution' do
          expect(alert.query['institution.uuid']).to eq(institution.uuid)
        end

        it 'should update the sites info' do
          expect(alert.query['site.uuid']).to include(site.uuid)
        end

        it 'should update the results info' do
          expect(alert.query['test.assays.result']).to include('positive')
        end

        it 'should update the sample id' do
          expect(alert.query['sample.id']).to eq('963')
        end

        it 'should update the roles' do
          alert_recipient = alert.alert_recipients.where(recipient_type: AlertRecipient.recipient_types['role']).first

          expect(alert_recipient.role.id).to eq(role.id)
        end

        it 'should update the internal alert recipients' do
          alert_recipient = alert.alert_recipients.where(recipient_type: AlertRecipient.recipient_types['internal_user']).first

          expect(alert_recipient.user.id).to eq(user2.id)
        end

        it 'should update the external alert recipients' do
          alert_recipient = alert.alert_recipients.where(recipient_type: AlertRecipient.recipient_types['external_user']).first

          expect(alert_recipient.email).to eq('external@user.com')
          expect(alert_recipient.telephone).to eq('444')
          expect(alert_recipient.first_name).to eq('External')
          expect(alert_recipient.last_name).to eq('User')
        end
      end

      context 'quantitative threshold' do
        let(:test_results_params) { alert_params.merge(test_result_min_threshold: '0', test_result_max_threshold: '835') }

        it 'should update the max result info' do
          expect(alert.query['test.assays.quantitative_result']).to eq({ 'from' => 0, 'to' => 835 })
        end
      end
    end
  end
end
