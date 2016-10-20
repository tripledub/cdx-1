require 'spec_helper'

describe Notification::Recipient do
  describe '#notification' do
    it { is_expected.to belong_to(:notification).class_name('Notification') }
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

  describe '#email_present?' do
    before { recipient.email = nil }
    it { expect(recipient.email_present?).to be(false) }
  end

  describe '#telephone_present?' do
    before { recipient.telephone = nil }
    it { expect(recipient.telephone_present?).to be(false) }
  end

end
