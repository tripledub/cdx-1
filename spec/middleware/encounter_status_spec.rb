require 'spec_helper'

RSpec.describe EncounterStatus do
  let(:institution)            { Institution.make }
  let(:user)                   { institution.user }
  let(:site)                   { institution.sites.make }
  let(:patient)                { Patient.make institution: institution }
  let(:encounter)              { Encounter.make institution: institution , user: user, patient: patient }
  let(:sample)                 { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let!(:sample_identifier1)    { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let!(:sample_identifier2)    { SampleIdentifier.make(site: site, entity_id: 'sample-2', sample: sample) }
  let(:requested_test)         { RequestedTest.make encounter: encounter, name: 'microscopy' }
  let(:culture_requested_test) { RequestedTest.make encounter: encounter }
  let(:new_requested_test)     { RequestedTest.make encounter: encounter }
  let(:dst_lpa_result)         { DstLpaResult.make requested_test: requested_test }
  let(:default_params)         { { context: institution.uuid } }
  let(:test_result)            { MicroscopyResult.make requested_test: requested_test }
  let(:culture_result)         { CultureResult.make requested_test: culture_requested_test }

  describe 'change_status' do
    context 'if some requested tests are pending or in progress' do
      before :each do
        culture_requested_test.update(status: :pending)
        described_class.change_status(encounter)
        encounter.reload
      end

      it 'should change the test order status to In progress' do
        expect(encounter.status).to eq('inprogress')
      end
    end

    context 'if all requested tests are completed or rejected' do
      before :each do
        described_class.change_status(encounter)
        encounter.reload
      end

      it 'should change the request order status to Completed' do
        expect(encounter.status).to eq('completed')
      end
    end
  end
end
