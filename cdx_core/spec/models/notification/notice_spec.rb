require 'spec_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

describe Notification::Notice do
  before(:all) { TestAfterCommit.enabled = true  }
  after(:all)  { TestAfterCommit.enabled = false }

  before do
    InstantNotificationJob.jobs.clear
    stub_const("Twilio::REST::Client", FakeSMS)
    FakeSMS.messages = []
  end

  context 'has relationship' do
    describe '#notification' do
      it { is_expected.to belong_to(:notification).class_name('Notification') }
    end

    describe '#notification_notice_group' do
      it { is_expected.to belong_to(:notification_notice_group).class_name('Notification::NoticeGroup') }
    end
  end

  context 'has method' do

    let!(:institution) { Institution.make(:with_contacts) }

    let!(:users) { [User.make(:with_contacts, institutions: [institution]), User.make(:with_contacts, institutions: [institution]), User.make(:with_contacts, institutions: [institution])] }
    let!(:notification_recipients) { [Notification::Recipient.make, Notification::Recipient.make, Notification::Recipient.make] }
    let!(:roles) { [institution.roles.last] }

    let!(:notification) do
      Notification.make(
        frequency: 'instant',
        users: users,
        notification_recipients: notification_recipients,
        roles: roles
      )
    end

    let!(:notice) { Notification::Notice.make(notification: notification) }

    describe '#users_and_role_users' do
      it { expect(notice.users_and_role_users).to match_array((notification.users + notification.role_users).uniq) }
    end

    describe '#recipients_union' do
      it { expect(notice.recipients_union).to match_array((notice.users_and_role_users + notification_recipients).uniq) }
    end

    context 'when delivering notifications' do
      before do
        notice.create_recipients
      end

      describe '#create_recipients' do
        it { expect(notice.notification_notice_recipients.size).to eq(notice.recipients_union.size) }
      end

      describe '#deliver_to_all_recipients' do
        before { notice.deliver_to_all_recipients }
        it { expect(ActionMailer::Base.deliveries.size).to eq(6) }
        it { expect(Twilio::REST::Client.messages.size).to eq(6) }
      end

    end

    describe '#complete!' do
      before do
        Timecop.freeze
        notice.complete!
      end

      after  { Timecop.return }

      it { expect(notice.notification.last_notification_at).to eq(Time.now) }
      it { expect(notice.status).to eq('complete') }
    end

    describe '#run_instant_job' do
      it { expect(InstantNotificationJob.jobs.size).to eq(1) }
    end
  end
end
