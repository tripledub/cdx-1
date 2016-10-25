require 'spec_helper'

describe Notification::Role do
  describe '#notification' do
    it { is_expected.to belong_to(:notification).class_name('Notification') }
  end

  describe '#role' do
    it { is_expected.to belong_to(:role).class_name('::Role') }
  end
end
