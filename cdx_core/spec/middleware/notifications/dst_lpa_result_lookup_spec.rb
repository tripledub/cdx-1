require 'spec_helper'

describe Notifications::DstLpaResultLookup do
  let(:patient) { Patient.make }
  let(:other_patient) { Patient.make }
  let(:encounter) { Encounter.make(patient: patient) }
  let(:encounter_without_patient) { Encounter.make(patient: other_patient) }

  let!(:notification_on_patient)           { Notification.make(institution: patient.institution, patient: patient) }
  let!(:notification_on_other_institution) { Notification.make(institution: other_patient.institution, encounter: encounter_without_patient, patient: other_patient) }
  let!(:notification_on_site)              { Notification.make(institution: patient.institution, site_ids: [dstlpa_result.encounter.site.id]) }

  let!(:dstlpa_result) { DstLpaResult.make(institution: patient.institution, encounter: encounter) }

  describe '#check_notifications' do
    let(:lookup) { described_class.new(dstlpa_result) }
    before { lookup.check_notifications }
    it { expect(lookup.notifications).to be_empty }
  end
end
