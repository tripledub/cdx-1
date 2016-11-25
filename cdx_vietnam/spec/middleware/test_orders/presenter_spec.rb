require 'spec_helper'

describe TestOrders::Presenter do
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:performing_site)     { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution, name: 'Nico McBrian' }
  let!(:encounters)         do
    7.times do
      Encounter.make institution: institution, site: site, patient: patient, start_time: 3.days.ago.to_s, testing_for: 'TB', performing_site: performing_site
    end
  end
  let(:requested_tests) do
    encounter = Encounter.first
    sample    = Sample.make(institution: institution, patient: patient, encounter: encounter)
    SampleIdentifier.make(site: site, cpd_id_sample: 'sample-1234',     sample: sample)
    SampleIdentifier.make(site: site, cpd_id_sample: 'sample-5678', sample: sample)
    microscopy_result = MicroscopyResult.make encounter: encounter
    CultureResult.make encounter: encounter
    xpert_result = XpertResult.make encounter: encounter
    dst_lpa_result = DstLpaResult.make encounter: encounter
    microscopy_result.update_attribute(:result_status, 'sample_collected')
    xpert_result.update_attribute(:result_status, 'allocated')
    dst_lpa_result.update_attribute(:result_status, 'rejected')
    encounter.reload
  end

  describe 'patient_view' do
    it 'should return an array of formated comments' do
      expect(TestOrders::Presenter.index_view(Encounter.all).size).to eq(7)
    end

    it 'should return elements formated' do
      requested_tests
      expect(TestOrders::Presenter.index_view(Encounter.all).first).to eq(
        id:                 Encounter.first.uuid,
        requestedSiteName:  site.name,
        performingSiteName: performing_site.name,
        sampleId:           'sample-1234, sample-5678',
        testingFor:         Encounter.first.testing_for,
        requestedBy:        user.full_name,
        batchId:            Encounter.first.batch_id,
        requestDate:        Extras::Dates::Format.datetime_with_time_zone(Encounter.first.start_time, :full_time),
        status:             'Samples received: Microscopy (Pending) - Culture (New) - Xpert (Allocated) - Dst/Lpa (Rejected)',
        viewLink:           Rails.application.routes.url_helpers.encounter_path(Encounter.first)
      )
    end
  end
end
