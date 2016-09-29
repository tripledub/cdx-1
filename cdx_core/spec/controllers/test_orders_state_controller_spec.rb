require 'spec_helper'

describe TestOrdersStateController do
  let(:institution)    { Institution.make }
  let(:user)           { institution.user }
  let(:patient)        { Patient.make institution: institution }
  let!(:test_order)    { Encounter.make patient: patient }
  let(:default_params) { { context: institution.uuid } }

  before :each do
    sign_in user
    User.current = user
    TestOrders::Status.update_and_log(test_order, 'samples_received')
  end

  describe 'index' do
    it 'should return a CSV file' do
      get :index, format: :csv
      csv = CSV.parse(response.body)
      expect(csv[0]).to eq(['Order ID', 'Previous state', 'Current state', 'Date'])
      expect(csv[1]).to eq(
        [
          test_order.batch_id,
          'new',
          'samples_received',
          Extras::Dates::Format.datetime_with_time_zone(test_order.created_at)
        ]
      )
    end
  end
end
