require 'spec_helper'

describe Notification::NoticeGroup do

  before(:each) do
    stub_const("Twilio::REST::Client", FakeSMS)
    FakeSMS.messages = []
  end

  describe '#status' do
    it { is_expected.to validate_inclusion_of(:status).in_array(Notification::NoticeGroup::STATUSES) }
  end

  describe '#frequency' do
    it { is_expected.to validate_inclusion_of(:frequency).in_array(Notification::FREQUENCY_TYPES.map(&:last)) }
  end

  describe '#triggered_at' do
    it { is_expected.to validate_presence_of(:triggered_at) }
  end

  describe '#last_digest_at' do
    let(:notice_group) { Notification::NoticeGroup.make }

    context 'when #frequency_value is \'hourly\'' do
      before { notice_group.frequency_value = 'hourly' }

      it { expect(notice_group.last_digest_at).to eq(notice_group.triggered_at - 1.hour) }
    end

    context 'when #frequency_value is \'daily\'' do
      before { notice_group.frequency_value ='daily'  }

      it { expect(notice_group.last_digest_at).to eq(notice_group.triggered_at - 1.day) }
    end

    context 'when #frequency_value is \'weekly\'' do
      before { notice_group.frequency_value = 'weekly' }

      it { expect(notice_group.last_digest_at).to eq(notice_group.triggered_at - 1.week) }
    end

    context 'when #frequency_value is \'monthly\'' do
      before { notice_group.frequency_value =  'monthly'}

      it { expect(notice_group.last_digest_at).to eq(notice_group.triggered_at - 1.month) }
    end

  end

  describe '#send_messages' do
    let!(:notice_group) do
      Notification::NoticeGroup.make(
        email_data: { 'example@example.com' => 1 },
        telephone_data: { '+441234 567 890' => 1 }
      )
    end

    context 'when #email_data contains 1 recipient' do
      it { expect(ActionMailer::Base.deliveries.size).to eq(1)}
    end

    context 'when #telephone_data contains 1 recipient' do
      it { expect(Twilio::REST::Client.messages.size).to eq(1)}
    end

  end
end
