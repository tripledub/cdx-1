require 'spec_helper'
require 'policy_spec_helper'

RSpec.describe AlertsHelper, type: :helper do
  let(:alert) { Alert.make }

  context 'alert history' do
    it 'should display an empty date' do
      expect(display_latest_alert_date(alert)).to eq('never')
    end

    it 'display_latest_alert_date' do
      Timecop.freeze(Time.utc(2013, 1, 15, 16, 32, 1))
      alert_history = AlertHistory.new
      alert_history.alert = alert
      alert_history.save
      Timecop.freeze(Time.utc(2016, 1, 16, 16, 32, 1))

      expect(display_latest_alert_date(alert)).to eq('3 years ago')

      Timecop.return
    end
  end
end
