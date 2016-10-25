require 'spec_helper'

describe Notifications::Gateway::Sms do
  before(:each) do
    stub_const("Twilio::REST::Client", FakeSMS)
    FakeSMS.messages = []
  end

  let(:gateway) { described_class.new(body: 'Test message') }

  describe '#credentials?' do
    context 'when \'phone_number\' and \'body\' are present' do
      before { gateway.phone_number = '1-711-751-9510' }
      it { expect(gateway.credentials?).to be(true) }
    end

    context 'when \'phone_number\' is missing' do
      before { gateway.phone_number = nil }
      it { expect(gateway.credentials?).to be(false) }
    end
  end

  describe '#send_message' do
    before do
      gateway.phone_number = '1-711-751-9510'
      gateway.send_message
    end

    it { expect(Twilio::REST::Client.messages.size).to eq(1) }
    it { expect(Twilio::REST::Client.messages.first.to).to eq('1-711-751-9510') }
    it { expect(Twilio::REST::Client.messages.first.body).to eq('Test message') }
  end
end
