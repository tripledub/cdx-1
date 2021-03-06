require 'spec_helper'

describe Notifications::XpertResultLookup do
  let(:patient) { Patient.make }
  let(:other_patient) { Patient.make }
  let(:encounter) { Encounter.make(patient: patient) }
  let(:encounter_without_patient) { Encounter.make(patient: other_patient) }

  let!(:notification_on_patient)           { Notification.make(name: 'Patient', institution: patient.institution, patient: patient) }
  let!(:notification_on_other_institution) { Notification.make(name: 'Other institution', institution: other_patient.institution, encounter: encounter_without_patient, patient: other_patient) }
  let!(:notification_on_site)              { Notification.make(name: 'Site', institution: patient.institution, site_ids: [xpert_result_tb_and_rif.encounter.site.id]) }

  let!(:xpert_result_no_detection) { XpertResult.make(encounter: encounter, tuberculosis: 'not_detected', rifampicin: 'not_detected') }
  let!(:xpert_result_tb_and_rif)   { XpertResult.make(encounter: encounter, tuberculosis: 'detected',     rifampicin: 'detected') }
  let!(:xpert_result_tb_only)      { XpertResult.make(encounter: encounter, tuberculosis: 'detected',     rifampicin: 'not_detected') }

  let(:lookup_no_detection) { described_class.new(xpert_result_no_detection) }
  let(:lookup_tb_and_rif)   { described_class.new(xpert_result_tb_and_rif) }
  let(:lookup_tb_only)      { described_class.new(xpert_result_tb_only) }

  before do
    @notification_on_pending_approval = Notification.make(name: 'Pending approval & tb detected', institution: patient.institution)
    @notification_on_pending_approval.notification_conditions.create!(condition_type: 'XpertResult', field: 'result_status', value: 'pending_approval')

    @notification_on_detected_mtb = Notification.make(name: 'tb detected', institution: patient.institution)
    @notification_on_detected_mtb.notification_conditions.create!(condition_type: 'XpertResult', field: 'tuberculosis', value: 'detected')

    @notification_on_detected_rif = Notification.make(name: 'rif detected', institution: patient.institution)
    @notification_on_detected_rif.notification_conditions.create!(condition_type: 'XpertResult', field: 'rifampicin', value: 'detected')
  end

  describe '#check_notifications' do
    context 'when status is \'pending_approval\'' do
      before do
        xpert_result_tb_only.result_status = 'pending_approval'
        xpert_result_tb_only.save!
        lookup_tb_only.check_notifications
      end

      it { expect(lookup_tb_only.notifications).to include(notification_on_patient, notification_on_site, @notification_on_detected_mtb, @notification_on_pending_approval) }
      it { expect(lookup_tb_only.notifications).not_to include(@notification_on_detected_rif, notification_on_other_institution) }
    end

    context 'when result is the same patient and site, no mtb or rif' do
      before { lookup_no_detection.check_notifications }

      it { expect(lookup_no_detection.notifications.size).to eq(2) }
      it { expect(lookup_no_detection.notifications).to include(notification_on_patient, notification_on_site) }
      it { expect(lookup_no_detection.notifications).not_to include(@notification_on_detected_mtb, @notification_on_detected_rif, notification_on_other_institution) }
    end

    context 'when result is the same patient and site, mtb detected no rif' do
      before do
        xpert_result_tb_only.result_status = 'completed'
        xpert_result_tb_only.save!
        lookup_tb_only.check_notifications
      end
      it { expect(lookup_tb_only.notifications.size).to eq(3) }
      it { expect(lookup_tb_only.notifications).to include(notification_on_patient, notification_on_site, @notification_on_detected_mtb) }
      it { expect(lookup_tb_only.notifications).not_to include(@notification_on_detected_rif, notification_on_other_institution) }
    end

    context 'when result is the same patient and site, mtb and rif detected' do
      before { lookup_tb_and_rif.check_notifications; }
      it { expect(lookup_tb_and_rif.notifications.size).to eq(4) }
      it { expect(lookup_tb_and_rif.notifications).to include(notification_on_patient, notification_on_site, @notification_on_detected_rif, @notification_on_detected_mtb) }
      it { expect(lookup_tb_and_rif.notifications).not_to include(notification_on_other_institution) }
    end
  end
end
