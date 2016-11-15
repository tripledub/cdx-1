require 'spec_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

describe CheckNotificationJob do
  before(:all) { TestAfterCommit.enabled = true  }
  after(:all)  { TestAfterCommit.enabled = false }
  describe '#perform' do
    let!(:encounter) { Encounter.make }
    before(:each) { described_class.jobs.clear }

    context 'when Encounter' do
      before { Encounter.make }

      it do
        expect(described_class.new.perform(*described_class.jobs.first['args']))
          .to be_an_instance_of(Notifications::EncounterLookup)
      end
    end

    xcontext 'when AssayResult' do
      before { AssayResult.make }

      it do
        expect(described_class.new.perform(*described_class.jobs.first['args']))
          .to be_an_instance_of(Notifications::AssayResultLookup)
      end
    end

    context 'when CultureResult' do
      before { CultureResult.make(encounter: encounter) }

      it do
        expect(described_class.new.perform(*described_class.jobs.first['args']))
          .to be_an_instance_of(Notifications::CultureResultLookup)
      end
    end

    context 'when DstLpaResult' do
      before { DstLpaResult.make(encounter: encounter) }

      it do
        expect(described_class.new.perform(*described_class.jobs.first['args']))
          .to be_an_instance_of(Notifications::DstLpaResultLookup)
      end
    end

    context 'when MicroscopyResult' do
      before { MicroscopyResult.make(encounter: encounter) }

      it do
        expect(described_class.new.perform(*described_class.jobs.first['args']))
          .to be_an_instance_of(Notifications::MicroscopyResultLookup)
      end
    end

    context 'when XpertResult' do
      before { XpertResult.make(encounter: encounter) }

      it do
        expect(described_class.new.perform(*described_class.jobs.first['args']))
          .to be_an_instance_of(Notifications::XpertResultLookup)
      end
    end
  end
end
