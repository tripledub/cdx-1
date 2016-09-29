require 'spec_helper'

describe TestOrders::CsvPresenter do
  let(:institution)    { Institution.make }
  let(:user)           { institution.user }
  let(:patient)        { Patient.make institution: institution }
  let!(:test_order)    { Encounter.make patient: patient, payment_done: true }
  let(:default_params) { { context: institution.uuid } }

  describe 'export_all' do
    subject { described_class.new(Encounter.all).export_all }

    before :each do
      User.current = user
      TestOrders::Status.update_and_log(test_order, 'samples_received')
      TestOrders::Status.update_and_log(test_order, 'samples_collected')
    end

    it 'should return an array of results' do
      csv = CSV.parse(subject)
      expect(csv[0]).to eq(['Order ID', 'Current state', 'Created', 'Last update'])
      expect(csv[1]).to eq(
        [
          test_order.batch_id,
          'new',
          'samples_received',
          Extras::Dates::Format.datetime_with_time_zone(test_order.created_at),
          Extras::Dates::Format.datetime_with_time_zone(test_order.updated_at)
        ]
      )
    end
  end
end
