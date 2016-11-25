require 'spec_helper'

describe Notification do

  let(:notification) { described_class.new }
  let(:patient) { Patient.make }
  let(:encounter) { Encounter.make }

  describe '#on_patient' do
    context 'when #patient_identifier is not set' do
      before { notification.patient_identifier = nil }

      it { expect(notification.on_patient).to be(false) }
    end

    context 'when #patient_identifier is set' do
      before { notification.patient_identifier = patient.id }

      it { expect(notification.on_patient).to be(true) }
    end
  end

  context 'when #patient_identifier is set with `patient#display_patient_id`' do
    before { notification.patient_identifier = patient.display_patient_id }

    it { expect(notification.on_patient).to be(true) }
  end

  describe '#on_test_order' do
    context 'when #test_identifier is not set' do
      before { notification.test_identifier = nil }

      it { expect(notification.on_test_order).to be(false) }
    end

    context 'when #test_identifier is set with `encounter#batch_id`' do
      before { notification.test_identifier = encounter.batch_id }

      it { expect(notification.on_test_order).to be(true) }
    end

    context 'when #test_identifier is set with `#id`' do
      before { notification.test_identifier = encounter.id }

      it { expect(notification.on_test_order).to be(true) }
    end

    context 'when #sample_identifier is not set' do
      before { notification.sample_identifier = nil }

      it { expect(notification.on_test_order).to be(false) }
    end
  end

  describe '#instant?' do
    context 'when #frequency is not \'instant\'' do
      before { notification.frequency = '' }

      it { expect(notification.instant?).to be(false) }
    end

    context 'when #frequency is \'instant\'' do
      before { notification.frequency = 'instant' }

      it { expect(notification.instant?).to be(true) }
    end
  end

  describe '#aggregate?' do
    context 'when #frequency is not \'aggregate\'' do
      before { notification.frequency = '' }

      it { expect(notification.aggregate?).to be(false) }
    end

    context 'when #frequency is \'aggregate\'' do
      before { notification.frequency = 'aggregate' }

      it { expect(notification.aggregate?).to be(true) }
    end
  end

  describe '#notification_statuses_names' do
    let(:notification_status) { Notification::Status.make }
    let(:notification_with_statuses) { notification_status.notification }

    context 'includes #test_status from Notification::Status' do
      it { expect(notification_with_statuses.notification_statuses_names).to include(notification_status.test_status) }
    end
  end

  describe '#enforce_nil_values' do
    context 'when empty strings' do
      let(:notification_with_blanks) { Notification.make(detection: '', detection_condition: '') }

      it { expect(notification_with_blanks).to be_valid }
      it { expect(notification_with_blanks.detection).to eq(nil) }
      it { expect(notification_with_blanks.detection_condition).to eq(nil) }
    end

    context 'with values' do
      let(:notification_with_blanks) { Notification.make(detection: 'mtb', detection_condition: 'positive') }

      it { expect(notification_with_blanks).to be_valid }
      it { expect(notification_with_blanks.detection).not_to eq(nil) }
      it { expect(notification_with_blanks.detection_condition).not_to eq(nil) }
    end
  end
end
