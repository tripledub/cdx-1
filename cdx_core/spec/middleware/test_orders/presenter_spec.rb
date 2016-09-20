require 'spec_helper'

describe TestOrders::Presenter do
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:performing_site)     { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution, name: 'Nico McBrian' }
  let!(:encounters)         {
    7.times {
      encounter = Encounter.make institution: institution, site: site, patient: patient, start_time: 3.days.ago.to_s, testdue_date: 1.day.from_now.to_s, testing_for: 'TB', performing_site: performing_site
      TestBatch.make encounter: encounter, institution: institution
      sample    = Sample.make(institution: institution, patient: patient, encounter: encounter)
      SampleIdentifier.make(site: site, entity_id: "sample-#{rand(1..30000)}",     sample: sample)
      SampleIdentifier.make(site: site, entity_id: "sample-#{rand(30001..60000)}", sample: sample)
    }
  }

  let(:requested_tests)     {
    encounter = Encounter.first
    microscopy_result = MicroscopyResult.make test_batch: encounter.test_batch
    culture_result = CultureResult.make test_batch: encounter.test_batch
    xpert_result = XpertResult.make test_batch: encounter.test_batch
    dst_lpa_result = DstLpaResult.make test_batch: encounter.test_batch
    microscopy_result.update_attribute(:result_status, 'sample_collected')
    xpert_result.update_attribute(:result_status, 'sample_received')
    dst_lpa_result.update_attribute(:result_status, 'rejected')
    encounter.reload
  }

  describe 'patient_view' do
    it 'should return an array of formated comments' do
      expect(described_class.index_view(Encounter.all).size).to eq(7)
    end

    it 'should return elements formated' do
      requested_tests
      expect(described_class.index_view(Encounter.all).first).to eq({
        id:                 Encounter.first.uuid,
        requestedSiteName:  site.name,
        performingSiteName: performing_site.name,
        sampleId:           Encounter.first.samples.map(&:entity_ids).join(', '),
        testingFor:         Encounter.first.testing_for,
        requestedBy:        user.full_name,
        batchId:            Encounter.first.batch_id,
        requestDate:        Extras::Dates::Format.datetime_with_time_zone(Encounter.first.start_time),
        dueDate:            Extras::Dates::Format.datetime_with_time_zone(Encounter.first.testdue_date),
        status:             'In progress: Batch (In progress) Microscopy (Sample collected) - Culture (New) - Xpert (Sample received) - Dst/Lpa (Rejected)',
        viewLink:           Rails.application.routes.url_helpers.encounter_path(Encounter.first)
      })
    end
  end
end