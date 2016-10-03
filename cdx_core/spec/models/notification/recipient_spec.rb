require 'spec_helper'

describe Notification::Recipient do
  describe '#notification' do
    it { is_expected.to belong_to(:notification).class_name('Notification') }
    it { is_expected.to validate_presence_of(:notification) }
  end

  let(:recipient) { described_class.make(notification: Notification.make(:instant)) }

  context 'when delivering messages' do
    before(:each) do
      stub_const("Twilio::REST::Client", FakeSMS)
      FakeSMS.messages = []
      ActionMailer::Base.deliveries.clear
    end

    describe '#send_sms' do
      before { recipient.send_sms }
      it { expect(Twilio::REST::Client.messages.size).to eq(1) }
    end

    describe '#send_email' do
      before { recipient.send_email }
      it { expect(ActionMailer::Base.deliveries.size).to eq(1) }
    end
  end

  describe '#missing_email?' do
    before { recipient.email = nil }
    it { expect(recipient.missing_email?).to be(true) }
  end

  describe '#missing_telephone?' do
    before { recipient.telephone = nil }
    it { expect(recipient.missing_telephone?).to be(true) }
  end

end
