require 'spec_helper'

describe TestOrders::ListCsv do
  let(:institution)       { Institution.make }
  let(:user)              { institution.user }
  let(:patient)           { Patient.make institution: institution }
  let!(:test_order)       { Encounter.make patient: patient }
  let(:microscopy_result) { MicroscopyResult.make encounter: test_order }
  let(:default_params)    { { context: institution.uuid } }

  describe 'generate' do
    subject { described_class.new(Encounter.all.order(:created_at), 'hostname').generate }

    it 'should return an array of test order status updates' do
      csv = CSV.parse(subject)
      expect(csv[0]).to eq(
        [
          'Test order ID',
          'Site',
          'Performing site',
          'Sample',
          'Testing for',
          'User',
          'Start time',
          'Test due date',
          'Status'
        ]
      )

      expect(csv[1]).to eq(
        [
          test_order.batch_id,
          Sites::Presenter.site_name(test_order.site),
          Sites::Presenter.site_name(test_order.performing_site),
          SampleIdentifiers::Presenter.for_encounter(test_order),
          test_order.testing_for,
          test_order.user.full_name,
          Extras::Dates::Format.datetime_with_time_zone(test_order.start_time, :full_time),
          Extras::Dates::Format.datetime_with_time_zone(test_order.testdue_date, :full_date),
          TestOrders::Presenter.generate_status(test_order)
        ]
      )
    end
  end

  describe 'filename' do
    subject { described_class.new(Encounter.all.order(:created_at), 'test.example.com') }

    it 'should include the hostname' do
      expect(subject.filename).to include('test.example.com')
    end
  end
end
