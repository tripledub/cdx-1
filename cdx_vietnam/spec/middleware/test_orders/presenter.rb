require 'spec_helper'

describe TestOrders::Presenter do
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:performing_site)     { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution, name: 'Nico McBrian' }
  let!(:encounters)         {
    7.times {
      encounter = Encounter.make institution: institution, site: site, patient: patient, start_time: 3.days.ago.to_s, status: 1, testing_for: 'TB', performing_site: performing_site
      sample    = Sample.make(institution: institution, patient: patient, encounter: encounter)
      SampleIdentifier.make(site: site, entity_id: "sample-#{rand(1..30000)}",     sample: sample)
      SampleIdentifier.make(site: site, entity_id: "sample-#{rand(30001..60000)}", sample: sample)
    }
  }
  let(:requested_tests)     {
    encounter = Encounter.first
    RequestedTest.make(encounter: encounter, status: :pending,    name: 'microscopy')
    encounter.reload
    RequestedTest.make(encounter: encounter, status: :inprogress, name: 'culture')
    encounter.reload
    RequestedTest.make(encounter: encounter, status: :completed,  name: 'dst')
    encounter.reload
    RequestedTest.make(encounter: encounter, status: :rejected,   name: 'xpert')
    encounter.reload
  }

  describe 'patient_view' do
    it 'should return an array of formated comments' do
      expect(TestOrders::Presenter.index_view(Encounter.all).size).to eq(7)
    end

    it 'should return elements formated' do
      requested_tests
      expect(TestOrders::Presenter.index_view(Encounter.all).first).to eq({
        id:                 Encounter.first.uuid,
        requestedSiteName:  site.name,
        performingSiteName: performing_site.name,
        sampleId:           Encounter.first.samples.map(&:entity_ids).join(', '),
        testingFor:         Encounter.first.testing_for,
        requestedBy:        user.full_name,
        requestDate:        Extras::Dates::Format.datetime_with_time_zone(Encounter.first.start_time),
        status:             'In progress: Microscopy (pending) - Culture (in progress) - Dst/Lpa (completed) - Xpert (rejected)',
        viewLink:           Rails.application.routes.url_helpers.encounter_path(Encounter.first)
      })
    end
  end
end
