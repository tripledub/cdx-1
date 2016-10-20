require 'spec_helper'

describe Notifications::MicroscopyResultLookup do
  let(:patient) { Patient.make }
  let(:other_patient) { Patient.make }
  let(:encounter) { Encounter.make(patient: patient) }
  let(:encounter_without_patient) { Encounter.make(patient: other_patient) }

  let!(:notification_on_patient)           { Notification.make(institution: patient.institution, patient: patient) }
  let!(:notification_on_other_institution) { Notification.make(institution: other_patient.institution, encounter: encounter_without_patient, patient: other_patient) }
  let!(:notification_on_site)              { Notification.make(institution: patient.institution, site_ids: [microscopy_result.encounter.site.id]) }

  let!(:microscopy_result) { MicroscopyResult.make(institution: patient.institution, encounter: encounter) }

  describe '#check_notifications' do
    let(:lookup) { described_class.new(microscopy_result) }
    before { lookup.check_notifications }
    it { expect(lookup.notifications).to include(notification_on_patient) }
  end
end
