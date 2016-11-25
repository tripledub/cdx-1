require 'spec_helper'

describe Notification::NoticeRecipient do

  before(:each) do
    stub_const("Twilio::REST::Client", FakeSMS)
    FakeSMS.messages = []
  end

  describe '#notification' do
    it { is_expected.to validate_presence_of(:notification) }
  end

  describe '#email' do
    let(:notice_recipient) { Notification::NoticeRecipient.make(notification: Notification.make(:instant)) }

    context 'is missing' do
      before do
        notice_recipient.email = nil
      end

      it { expect(notice_recipient.valid?).to be(true) }
    end

    context 'is invalid' do
      before do
        notice_recipient.email = 'invalidemail(at)example.com'
      end

      it { expect(notice_recipient.valid?).not_to be(true) }
    end

    context 'is missing and #telephone is missing' do
      before do
        notice_recipient.telephone = nil
        notice_recipient.email = nil
      end

      it { expect(notice_recipient.valid?).not_to be(true) }
    end
  end

  describe '#telephone' do
    it { expect(described_class.new).to have(1).error_on(:telephone)}
  end

  describe '#send_sms' do
    let(:notice_recipient) { Notification::NoticeRecipient.make(notification: Notification.make(:instant)) }
    after { Twilio::REST::Client.messages = [] }

    context 'when #telephone is blank' do
      before do
        notice_recipient.telephone = nil
        notice_recipient.send_sms
      end
      it { expect(Twilio::REST::Client.messages.size).to eq(0) }
    end

    context 'when #telephone is a phone number' do
      before do
        notice_recipient.telephone = Faker::PhoneNumber.phone_number
        notice_recipient.send_sms
      end
      it { expect(Twilio::REST::Client.messages.size).to eq(1) }
    end
  end

  describe '#send_email' do
    let(:notice_recipient) { Notification::NoticeRecipient.make(notification: Notification.make(:instant)) }
    after { ActionMailer::Base.deliveries.clear }

    context 'when #email is blank' do
      before do
        notice_recipient.email = nil
        notice_recipient.send_email
      end
      it { expect(ActionMailer::Base.deliveries.size).to eq(0) }
    end

    context 'when #email is a phone number' do
      before do
        notice_recipient.email = Faker::Internet.email
        notice_recipient.send_email
      end
      it { expect(ActionMailer::Base.deliveries.size).to eq(1) }
    end
  end
end
