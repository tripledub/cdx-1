require 'spec_helper'

describe Presenters::TestOrders do
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:performing_site)     { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution, name: 'Nico McBrian' }

  describe 'patient_view' do
    before :each do
      7.times {
        encounter = Encounter.make institution: institution, site: site, patient: patient, start_time: 3.days.ago.to_s, testdue_date: 1.day.from_now.to_s, status: 2, testing_for: 'TB', performing_site: performing_site
        sample    = Sample.make(institution: institution, patient: patient, encounter: encounter)
        SampleIdentifier.make(site: site, entity_id: "sample-#{rand(1..3000)}", sample: sample)
        SampleIdentifier.make(site: site, entity_id: "sample-#{rand(3001..6000)}", sample: sample)
      }
      @tests = Encounter.all
    end

    it 'should return an array of formated comments' do
      expect(Presenters::TestOrders.index_view(Encounter.all).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(Presenters::TestOrders.index_view(Encounter.all).first).to eq({
        id:                 Encounter.first.uuid,
        requestedSiteName:  site.name,
        performingSiteName: performing_site.name,
        sampleId:           Encounter.first.samples.map(&:entity_ids).join(', '),
        testingFor:         Encounter.first.testing_for,
        requestedBy:        user.full_name,
        requestDate:        Extras::Dates::Format.datetime_with_time_zone(Encounter.first.start_time),
        dueDate:            Extras::Dates::Format.datetime_with_time_zone(Encounter.first.testdue_date),
        status:             'Completed',
        viewLink:           Rails.application.routes.url_helpers.encounter_path(Encounter.first)
      })
    end
  end
end
