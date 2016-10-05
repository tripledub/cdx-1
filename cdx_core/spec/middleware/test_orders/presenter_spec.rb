require 'spec_helper'

describe TestOrders::Presenter do
  let(:user)                { User.make }
  let!(:institution)        { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:performing_site)     { Site.make institution: institution }
  let(:patient)             { Patient.make institution: institution, name: 'Nico McBrian' }
  let!(:encounters)         {
    7.times do
      Encounter.make institution: institution, site: site, patient: patient, start_time: 3.days.ago.to_s, testdue_date: 1.day.from_now.to_s, testing_for: 'TB', performing_site: performing_site
    end
  }

  let(:requested_tests) do
    encounter = Encounter.first
    microscopy_result = MicroscopyResult.make encounter: encounter, serial_number: 'XF-999'
    culture_result = CultureResult.make encounter: encounter, serial_number: 'XF-966'
    xpert_result = XpertResult.make encounter: encounter, serial_number: 'XF-977'
    dst_lpa_result = DstLpaResult.make encounter: encounter, serial_number: 'XF-988'
    microscopy_result.update_attribute(:result_status, 'sample_collected')
    xpert_result.update_attribute(:result_status, 'allocated')
    dst_lpa_result.update_attribute(:result_status, 'rejected')
    encounter.reload
  end

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
        sampleId:           'XF-999, XF-966, XF-977, XF-988',
        testingFor:         Encounter.first.testing_for,
        requestedBy:        user.full_name,
        batchId:            Encounter.first.batch_id,
        requestDate:        Extras::Dates::Format.datetime_with_time_zone(Encounter.first.start_time),
        dueDate:            Extras::Dates::Format.datetime_with_time_zone(Encounter.first.testdue_date),
        status:             'In progress: Microscopy (Sample collected) - Culture (New) - Xpert (Allocated) - Dst/Lpa (Rejected)',
        paymentDone:        Encounter.first.payment_done,
        viewLink:           Rails.application.routes.url_helpers.encounter_path(Encounter.first)
      })
    end
  end
end
