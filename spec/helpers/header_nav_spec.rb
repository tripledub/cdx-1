require 'spec_helper'

RSpec.describe HeaderNavHelper, type: :helper do
  let(:params_dashboard)      { { controller: 'dashboards' } }
  let(:params_patients)       { { controller: 'patients' } }
  let(:params_test_orders)    { { controller: 'test_orders' } }
  let(:params_test_results)   { { controller: 'test_results' } }
  let(:params_devices)        { { controller: 'devices' } }
  let(:params_roles)          { { controller: 'roles' } }
  let(:params_policies)       { { controller: 'policies' } }
  let(:params_incidents)      { { controller: 'incidents' } }
  let(:params_alert_messages) { { controller: 'alert_messages' } }
  let(:params_alerts)         { { controller: 'alerts' } }
  let(:params_device_models)  { { controller: 'device_models' } }
  let(:params_users)          { { controller: 'users' } }

  describe 'is_menu_item_active?' do
    context 'dashboards' do
      it 'should return true if controller is a dashboards' do
        expect(helper.is_menu_item_active?('dashboards', params_dashboard)).to eq('active')
      end

      it 'should return false if controller is not a dashboards' do
        expect(helper.is_menu_item_active?('dashboards', params_patients)).to eq('')
      end
    end

    context 'patients' do
      it 'should return true if controller is a patients' do
        expect(helper.is_menu_item_active?('patients', params_patients)).to eq('active')
      end

      it 'should return false if controller is not a patients' do
        expect(helper.is_menu_item_active?('patients', params_dashboard)).to eq('')
      end
    end

    context 'test_orders' do
      it 'should return true if controller is a test_orders' do
        expect(helper.is_menu_item_active?('test_orders', params_test_orders)).to eq('active')
      end

      it 'should return false if controller is not a test_orders' do
        expect(helper.is_menu_item_active?('test_orders', params_test_results)).to eq('')
      end
    end

    context 'test_results' do
      it 'should return true if controller is a test_results' do
        expect(helper.is_menu_item_active?('test_results', params_test_results)).to eq('active')
      end

      it 'should return false if controller is not a test_results' do
        expect(helper.is_menu_item_active?('test_results', params_test_orders)).to eq('')
      end
    end

    context 'devices' do
      it 'should return true if controller is a devices' do
        expect(helper.is_menu_item_active?('devices', params_devices)).to eq('active')
      end

      it 'should return false if controller is not a devices' do
        expect(helper.is_menu_item_active?('devices', params_dashboard)).to eq('')
      end
    end

    context 'settings' do
      it 'should return true if controller is a roles' do
        expect(helper.is_menu_item_active?('settings', params_roles)).to eq('active')
      end

      it 'should return true if controller is a policies' do
        expect(helper.is_menu_item_active?('settings', params_policies)).to eq('active')
      end

      it 'should return true if controller is a alerts' do
        expect(helper.is_menu_item_active?('settings', params_alerts)).to eq('active')
      end

      it 'should return true if controller is a incidents' do
        expect(helper.is_menu_item_active?('settings', params_incidents)).to eq('active')
      end

      it 'should return true if controller is a alert_messages' do
        expect(helper.is_menu_item_active?('settings', params_alert_messages)).to eq('active')
      end

      it 'should return true if controller is a device_models' do
        expect(helper.is_menu_item_active?('settings', params_device_models)).to eq('active')
      end

      it 'should return true if controller is a users' do
        expect(helper.is_menu_item_active?('settings', params_users)).to eq('active')
      end

      it 'should return false if controller is not a settings' do
        expect(helper.is_menu_item_active?('settings', params_dashboard)).to eq('')
      end
    end
  end
end
