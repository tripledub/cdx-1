require 'spec_helper'

describe Notifications::TestResultLookup do
  let!(:institution)   { Institution.make }
  let!(:test_result)   { TestResult.make(institution: institution, device: Device.make(site: Site.make(institution: institution))) }
  let!(:other_patient) { Patient.make }
  let!(:encounter_without_patient) { Encounter.make(patient: other_patient) }

  let!(:notification_on_patient)           { Notification.make(institution: institution, patient: test_result.patient) }
  let!(:notification_on_other_institution) { Notification.make(institution: other_patient.institution, encounter: encounter_without_patient, patient: other_patient) }
  let!(:notification_on_site)              { Notification.make(institution: institution, site_ids: [test_result.device.site.id]) }

  describe '#check_notifications' do
    let(:lookup) { described_class.new(test_result) }
    before { lookup.check_notifications }
    it { expect(lookup.notifications).to be_empty }
  end
end
