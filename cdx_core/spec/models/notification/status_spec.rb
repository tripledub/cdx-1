require 'spec_helper'

describe Notification::Status do
  describe '#notification' do
    it { is_expected.to belong_to(:notification).class_name('Notification') }
    it { is_expected.to validate_presence_of(:notification) }
  end

  describe '#test_status' do
    it { is_expected.to validate_presence_of(:test_status) }
    it { is_expected.to validate_uniqueness_of(:test_status).scoped_to(:notification_id) }
  end
end
