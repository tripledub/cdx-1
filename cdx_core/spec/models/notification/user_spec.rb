require 'spec_helper'

describe Notification::User do
  describe '#notification' do
    it { is_expected.to belong_to(:notification).class_name('Notification') }
    it { is_expected.to validate_presence_of(:notification) }
  end

  describe '#user' do
    it { is_expected.to belong_to(:user).class_name('::User') }
    it { is_expected.to validate_presence_of(:user) }
  end
end
