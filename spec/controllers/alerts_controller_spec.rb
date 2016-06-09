require 'spec_helper'
require 'policy_spec_helper'

describe AlertsController, type: :controller, elasticsearch: true do
  render_views
  let!(:user)          { User.make }
  let!(:institution)   { user.create Institution.make_unsaved }
  let(:default_params) { { context: institution.uuid } }

  let(:root_location) { Location.make }
  let(:location)      { Location.make parent: root_location }
  let(:site)          { Site.make institution: institution, location: location }
  let(:site2)         { Site.make institution: institution, location: location }
  let(:subsite)       { Site.make institution: institution, location: location, parent: site }
  let(:device)        { Device.make institution_id: institution.id, site: site }
  let(:device2)       { Device.make institution_id: institution.id, site: site }
  let(:alert)         { Alert.make institution_id: institution.id }
  let(:alert_params)  { {
    name:         'Updated alert',
    devices_info: "#{device2.id}, #{device.id}",
    sites_info:   "#{site2.id}, #{site.id}"
  }}

  before :each do
    sign_in user
  end

  describe 'update' do
    context 'with valid data' do
      before :each do
        post :update, id: alert.id, alert: alert_params
        alert.reload
      end

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
    end
  end
end
