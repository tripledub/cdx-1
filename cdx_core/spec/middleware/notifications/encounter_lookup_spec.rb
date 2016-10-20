require 'spec_helper'

describe Notifications::EncounterLookup do
  let!(:patient) { Patient.make }
  let!(:other_patient) { Patient.make }
  let!(:encounter) { Encounter.make(patient: patient) }
  let!(:encounter_other_patient) { Encounter.make(patient: other_patient) }

  let!(:notification_on_patient)           { Notification.make(name: 'Patient alert',   institution: patient.institution, patient: patient) }
  let!(:notification_on_other_institution) { Notification.make(name: 'Other Patient & encounter alert', institution: other_patient.institution, encounter: encounter_other_patient, patient: other_patient) }
  let!(:notification_on_site)              { Notification.make(name: 'Site alert', institution: patient.institution, site_ids: [encounter.site.id]) }
  let!(:notification_on_samples_received)  { Notification.make(name: 'Encounter[samples received]', institution: patient.institution, notification_statuses_names: ['samples_received']) }
  let!(:notification_on_pending_approval)  { Notification.make(name: 'Encounter[pending approval]', institution: patient.institution, notification_statuses_names: ['pending_approval']) }

  let(:lookup) { Notifications::EncounterLookup.new(encounter) }

  describe '#check_notifications' do
    context 'notify on patient and site' do
      before { lookup.check_notifications }
      it { expect(lookup.notifications.size).to eq(2) }
      it { expect(lookup.notifications).to include(notification_on_patient, notification_on_site) }
    end

    context 'notification from different institution' do
      before { lookup.check_notifications }
      it { expect(lookup.notifications).not_to include(notification_on_other_institution) }
    end
  end

  describe '#create_notices_from_notifications' do
    context 'notify on patient and site' do
      before do
        lookup.check_notifications
        lookup.create_notices_from_notifications
      end

      it { expect { lookup.create_notices_from_notifications }.to change { Notification::Notice.count }.by(2)}
    end

    context 'notification from different institution' do
      before do
        lookup.check_notifications
        lookup.create_notices_from_notifications

        it { expect { lookup.create_notices_from_notifications }.to change { Notification::Notice.count }.by(2)}
      end
    end

  end
end
