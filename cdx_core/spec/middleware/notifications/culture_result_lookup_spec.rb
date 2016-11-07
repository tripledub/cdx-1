require 'spec_helper'

describe Notifications::CultureResultLookup do
  let(:patient) { Patient.make }
  let(:other_patient) { Patient.make }
  let(:encounter) { Encounter.make(patient: patient) }
  let(:encounter_without_patient) { Encounter.make(patient: other_patient) }

  let!(:notification_on_patient)           { Notification.make(institution: patient.institution, patient: patient) }
  let!(:notification_on_other_institution) { Notification.make(institution: other_patient.institution, encounter: encounter_without_patient, patient: other_patient) }
  let!(:notification_on_site)              { Notification.make(institution: patient.institution, site_ids: [culture_result.encounter.site.id]) }

  let!(:culture_result) { CultureResult.make(encounter: encounter) }

  before do
    @notification_on_pending_approval = Notification.make(name: 'Pending approval & tb detected', institution: patient.institution)
    @notification_on_pending_approval.notification_conditions.create!(condition_type: 'CultureResult', field: 'result_status', value: 'pending_approval')

    @notification_on_detected_mtb = Notification.make(name: 'tb detected', institution: patient.institution)
    @notification_on_detected_mtb.notification_conditions.create!(condition_type: 'CultureResult', field: 'media_used', value: 'solid')

    @notification_on_detected_rif = Notification.make(name: 'rif detected', institution: patient.institution)
    @notification_on_detected_rif.notification_conditions.create!(condition_type: 'CultureResult', field: 'test_result', value: 'contaminated')
  end

  describe '#check_notifications' do
    let(:lookup) { described_class.new(culture_result) }
    before { lookup.check_notifications }
    it { expect(lookup.notifications).to include(notification_on_patient) }
  end
end
