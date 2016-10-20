require 'spec_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

describe InstantNotificationJob do
  before(:all) { TestAfterCommit.enabled = true  }
  after(:all)  { TestAfterCommit.enabled = false }
  before(:all) { InstantNotificationJob.jobs.clear }

  describe '#perform' do
    let!(:encounter) { Encounter.make  }
    let!(:notification) do
      Notification.make(
        institution: encounter.institution,
        encounter:   encounter,
        patient:     encounter.patient,
        notification_statuses_names: ['sample_collected'],
        frequency:  'instant'
      )
    end

    let!(:xpert_result) do
      XpertResult.make(
        institution: encounter.patient.institution,
        encounter: encounter,
        result_status: 'new'
      )
    end

    let!(:other_notification) do
      Notification.make(
        institution: encounter.institution,
        encounter:   encounter,
        notification_statuses_names: ['pending_approval'],
        frequency:  'instant'
      )
    end

    before { CheckNotificationJob.clear }

    context 'when xpert_result#status is \'sample_collected\'' do
      before do
        xpert_result.result_status = 'sample_collected'
        xpert_result.save!
        CheckNotificationJob.drain
      end

      after { InstantNotificationJob.jobs.clear }

      it { expect(InstantNotificationJob.jobs.size).to eq(1) }
      it { expect(notification.notification_notices.size).to eq(1) }
    end

    context 'when encounter#status is \'pending\'' do
      before do
        encounter.status = 'pending'
        encounter.save!
        CheckNotificationJob.drain
      end

      after { InstantNotificationJob.jobs.clear }

      it { expect(InstantNotificationJob.jobs.size).to eq(0) }
      it { expect(notification.notification_notices.size).to eq(0) }
    end

    after { CheckNotificationJob.jobs.clear }
  end
end
