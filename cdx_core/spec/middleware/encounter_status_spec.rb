require 'spec_helper'

RSpec.describe Encounter::Status do
  let(:institution)            { Institution.make }
  let(:user)                   { institution.user }
  let(:site)                   { institution.sites.make }
  let(:patient)                { Patient.make   institution: institution }
  let(:encounter)              { Encounter.make institution: institution , user: user, patient: patient }
  let(:sample)                 { Sample.make    institution: institution, patient: patient, encounter: encounter }
  let(:sample_identifier1)     { SampleIdentifier.make site: site, entity_id: 'sample-id', sample: sample }
  let(:sample_identifier2)     { SampleIdentifier.make site: site, entity_id: 'sample-2',  sample: sample }
  let(:dst_lpa_requested_test) { RequestedTest.make encounter: encounter, name: 'microscopy' }
  let(:culture_requested_test) { RequestedTest.make encounter: encounter, name: 'culture' }
  let(:xpert_requested_test)   { RequestedTest.make encounter: encounter, name: 'xpertmtb' }
  let(:default_params)         { { context: institution.uuid } }

  describe 'change_status' do
    context 'if some requested tests are in progress' do
      before :each do
        culture_requested_test.update(status: :inprogress)
        described_class.change_status(encounter)
        encounter.reload
      end

      it 'should change the test order status to In progress' do
        expect(encounter.status).to eq('inprogress')
      end
    end

    context 'if requested tests are pending' do
      before :each do
        culture_requested_test.update(status: :pending)
        described_class.change_status(encounter)
        encounter.reload
      end

      it 'should change the test order status to pending' do
        expect(encounter.status).to eq('pending')
      end
    end


    context 'if all requested tests are rejected' do
      before :each do
        culture_requested_test.update(status: :rejected)
        dst_lpa_requested_test.update(status: :rejected)
        xpert_requested_test.update(status: :rejected)
        encounter.reload
      end

      it 'should change the request order status to Completed' do
        expect(encounter.status).to eq('completed')
      end
    end

    context 'if all requested tests are completed' do
      before :each do
        culture_requested_test.update(status: :completed)
        dst_lpa_requested_test.update(status: :completed)
        xpert_requested_test.update(status: :completed)
        encounter.reload
      end

      it 'should change the request order status to Completed' do
        expect(encounter.status).to eq('completed')
      end
    end

    context 'if all requested tests are completed or rejected' do
      before :each do
        culture_requested_test.update(status: :completed)
        dst_lpa_requested_test.update(status: :rejected)
        xpert_requested_test.update(status: :completed)
        encounter.reload
      end

      it 'should change the request order status to Completed' do
        expect(encounter.status).to eq('completed')
      end
    end
  end
end
