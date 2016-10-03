require 'spec_helper'

describe Notification::Device do
  describe '#device' do
    it { is_expected.to validate_presence_of(:device) }
  end

  describe '#notification' do
    it { is_expected.to validate_presence_of(:notification) }
  end
end
