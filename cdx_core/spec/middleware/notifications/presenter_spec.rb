require 'spec_helper'
include ActionView::Helpers::TextHelper

describe Notifications::Presenter do
  before(:each) do
    10.times { Notification.make }
  end

  describe '::index_table' do

    let(:notification) { Notification.first }

    it { expect(described_class.index_table(Notification.all).size).to eq(10) }

    it do
      expect(described_class.index_table(Notification.all).first).to eq({
        id:           notification.id,
        name:         truncate(notification.name, length: 20),
        description:  truncate(notification.description, length: 20),
        enabled:      described_class.send(:show_enabled, notification.enabled),
        sites:        notification.sites.map(&:name).join(', '),
        roles:        notification.roles.map(&:name).join(', '),
        lastIncident: notification.last_notification_at,
        viewLink:     Rails.application.routes.url_helpers.edit_notification_path(notification)
      })
    end
  end
end
