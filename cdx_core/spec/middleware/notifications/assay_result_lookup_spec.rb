require 'spec_helper'

describe Notifications::AssayResultLookup do
  let!(:institution)   { Institution.make }
  let!(:test_result)   { TestResult.make(institution: institution, device: Device.make(site: Site.make(institution: institution))) }

  let!(:patient) { Patient.make(institution: institution) }
  let!(:other_patient) { Patient.make }
  let!(:encounter) { Encounter.make(patient: patient) }
  let!(:encounter_other_patient) { Encounter.make(patient: other_patient) }

  let!(:notification_on_patient)           { Notification.make(name: 'Patient alert',   institution: patient.institution, patient: patient) }
  let!(:notification_on_other_institution) { Notification.make(name: 'Other Patient & encounter alert', institution: other_patient.institution, encounter: encounter_other_patient, patient: other_patient) }
  let!(:notification_on_site)              { Notification.make(name: 'Site alert', institution: patient.institution, site_ids: [test_result.device.site.id]) }

  let!(:notification_on_detected_mtb)      { Notification.make(name: 'Checking for mtb', institution: patient.institution, detection: 'mtb', detection_condition: 'positive') }
  let!(:notification_on_detected_rif)      { Notification.make(name: 'Detected rif', institution: patient.institution, detection: 'rif', detection_condition: 'positive') }

  let!(:notification_on_detected_mtb_negative) { Notification.make(name: 'Detected mtb-', institution: patient.institution, detection: 'mtb', detection_condition: 'negative') }
  let!(:notification_on_detected_rif_negative) { Notification.make(name: 'd rif-', institution: patient.institution, detection: 'rif', detection_condition: 'negative') }
  let!(:notification_on_detected_mtb_high)     { Notification.make(name: 'd mtb h', institution: patient.institution, detection: 'mtb', detection_condition: 'positive', detection_quantitative_result: 'HIGH') }

  describe '#check_notifications' do
    context 'when mtb is detected' do
      before do
        assay_result = AssayResult.make(assayable: test_result, condition: 'mtb', result: 'positive')
        @lookup = described_class.new(assay_result)
        @lookup.check_notifications
      end

      it { expect(@lookup.notifications.size).to eq(3) }
    end

    context 'when mtb is not detected' do
      before do
        assay_result = AssayResult.make(assayable: test_result, condition: 'mtb', result: 'negative')
        @lookup = described_class.new(assay_result)
        @lookup.check_notifications
      end

      it { expect(@lookup.notifications.size).to eq(3) }
    end

    context 'when mtb \'HIGH\' is detected' do
      before do
        assay_result = AssayResult.make(assayable: test_result, condition: 'mtb', result: 'positive', quantitative_result: 'HIGH')
        @lookup = described_class.new(assay_result)
        @lookup.check_notifications
      end

      it { expect(@lookup.notifications.size).to eq(4) }
    end
  end
end
