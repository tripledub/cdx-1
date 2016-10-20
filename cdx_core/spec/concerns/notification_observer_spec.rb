require 'spec_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

describe 'NotificationObserver' do
  describe Encounter do
    describe '@@_notification_observed_fields' do
      it { expect(described_class._notification_observed_fields).to eq([:status]) }
    end

    describe '::_has_observable_fields?' do
      it { expect(described_class._has_observable_fields?).to be(true) }
    end

    describe '#_fire_check_notification_job' do
      before(:each) { TestAfterCommit.enabled = true  }
      after(:each)  { TestAfterCommit.enabled = false }

      let!(:encounter) { Encounter.make }

      before { CheckNotificationJob.jobs.clear }

      context 'when observed field changes number of jobs' do
        before do
          encounter.status = 'financed'
          encounter.save!
        end

        it { expect(CheckNotificationJob.jobs.size).to eq(1) }
      end

      context 'when observed field does not change number of jobs' do
        it { expect(CheckNotificationJob.jobs.size).to eq(0) }
      end
    end
  end
end
