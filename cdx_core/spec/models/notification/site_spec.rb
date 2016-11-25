require 'spec_helper'

describe Notification::Site do
  describe '#notification' do
    it { is_expected.to belong_to(:notification).class_name('Notification') }
  end

  describe '#site' do
    it { is_expected.to belong_to(:site).class_name('::Site') }
  end
end
