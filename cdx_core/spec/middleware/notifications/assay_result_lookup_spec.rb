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

  describe '#check_notifications' do

    before do
      @notification_on_detected_mtb = Notification.make(name: 'Checking for mtb', institution: patient.institution)
      @notification_on_detected_mtb.notification_conditions.create!(condition_type: 'AssayResult', field: 'condition', value: 'mtb')
      @notification_on_detected_mtb.notification_conditions.create!(condition_type: 'AssayResult', field: 'result', value: 'positive')
      @notification_on_detected_mtb.notification_conditions.create!(condition_type: 'AssayResult', field: 'quantitative_result', value: 'low')
      
      @notification_on_detected_rif = Notification.make(name: 'Detected rif', institution: patient.institution)
      @notification_on_detected_rif.notification_conditions.create!(condition_type: 'AssayResult', field: 'condition', value: 'rif')
      @notification_on_detected_rif.notification_conditions.create!(condition_type: 'AssayResult', field: 'result', value: 'positive')
      @notification_on_detected_rif.notification_conditions.create!(condition_type: 'AssayResult', field: 'quantitative_result', value: 'low')

      @notification_on_detected_mtb_negative = Notification.make(name: 'Detected mtb-', institution: patient.institution)
      @notification_on_detected_mtb_negative.notification_conditions.create!(condition_type: 'AssayResult', field: 'condition', value: 'mtb')
      @notification_on_detected_mtb_negative.notification_conditions.create!(condition_type: 'AssayResult', field: 'result', value: 'negative')
      
      @notification_on_detected_rif_negative = Notification.make(name: 'd rif-', institution: patient.institution)
      @notification_on_detected_rif_negative.notification_conditions.create!(condition_type: 'AssayResult', field: 'condition', value: 'rif')
      @notification_on_detected_rif_negative.notification_conditions.create!(condition_type: 'AssayResult', field: 'result', value: 'negative')
      
      @notification_on_detected_mtb_high = Notification.make(name: 'd mtb h', institution: patient.institution)
      @notification_on_detected_mtb_high.notification_conditions.create!(condition_type: 'AssayResult', field: 'condition', value: 'mtb')
      @notification_on_detected_mtb_high.notification_conditions.create!(condition_type: 'AssayResult', field: 'result', value: 'positive')
      @notification_on_detected_mtb_high.notification_conditions.create!(condition_type: 'AssayResult', field: 'quantitative_result', value: 'high')
    end

    context 'when mtb is detected' do
      let(:assay_result) { AssayResult.make(assayable: test_result, condition: 'mtb', result: 'positive', quantitative_result: 'low') }
      let(:lookup) { described_class.new(assay_result) }
      before { lookup.check_notifications }

      it { expect(lookup.notifications.size).to eq(3) }
    end

    context 'when mtb is not detected' do
      let(:assay_result) { AssayResult.make(assayable: test_result, condition: 'mtb', result: 'negative', quantitative_result: nil) }
      let(:lookup) { described_class.new(assay_result) }
      before { lookup.check_notifications }

      it { expect(lookup.notifications.size).to eq(2) }
    end

    context 'when mtb \'HIGH\' is detected' do
      let(:assay_result) { AssayResult.make(assayable: test_result, condition: 'mtb', result: 'positive', quantitative_result: 'high') }
      let(:lookup) { described_class.new(assay_result) }
      before { lookup.check_notifications }

      it { expect(lookup.notifications.size).to eq(3) }
    end
  end
end
