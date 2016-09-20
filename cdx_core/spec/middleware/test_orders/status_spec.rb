require 'spec_helper'

RSpec.describe TestOrders::Status do
  let(:institution)            { Institution.make }
  let(:user)                   { institution.user }
  let(:site)                   { institution.sites.make }
  let(:patient)                { Patient.make   institution: institution }
  let(:encounter)              { Encounter.make institution: institution , user: user, patient: patient, test_batch: TestBatch.make }
  let(:default_params)         { { context: institution.uuid } }

  describe 'change_status' do
    context 'pending' do
      it 'should be set to pending if test batch has been paid and samples are collected' do
        encounter.test_batch.payment_done = true
        encounter.test_batch.status       = 'samples_collected'
        encounter.test_batch.save

        expect(encounter.status).to eq('pending')
      end
    end
  end
end
