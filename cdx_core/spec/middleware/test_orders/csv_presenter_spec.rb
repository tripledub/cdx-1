require 'spec_helper'

describe TestOrders::CsvPresenter do
  let(:institution)       { Institution.make }
  let(:user)              { institution.user }
  let(:patient)           { Patient.make institution: institution }
  let!(:test_order)       { Encounter.make patient: patient }
  let(:microscopy_result) { MicroscopyResult.make encounter: test_order }
  let(:default_params)    { { context: institution.uuid } }

  describe 'export_all' do
    subject { described_class.new(Encounter.all).export_all }

    before :each do
      User.current = user
      TestOrders::Status.update_and_log(test_order, 'samples_received')
      TestOrders::Status.update_and_log(test_order, 'samples_collected')
    end

    it 'should return an array of test order status updates' do
      csv = CSV.parse(subject)
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

  describe 'export_one' do
    subject { described_class.new(test_order).export_one }

    before :each do
      User.current = user
      PatientResults::StatusAuditor.create_status_log(microscopy_result, %w(new pending_approval))
      PatientResults::StatusAuditor.create_status_log(microscopy_result, %w(pending_approval rejected))
      microscopy_result.reload
    end

    it 'should return an array of patient results status update' do
      csv = CSV.parse(subject)
      expect(csv[0]).to eq(['Order ID', 'Sample ID', 'Previous state', 'Current state', 'Date'])
      expect(csv[1]).to eq(
        [
          test_order.batch_id,
          microscopy_result.serial_number,
          'new',
          'pending_approval',
          Extras::Dates::Format.datetime_with_time_zone(test_order.created_at)
        ]
      )
    end
  end
end
