require 'spec_helper'

describe TestOrders::AuditCsv do
  let(:institution)       { Institution.make }
  let(:user)              { institution.user }
  let(:patient)           { Patient.make institution: institution }
  let!(:test_order)       { Encounter.make patient: patient }
  let(:microscopy_result) { MicroscopyResult.make encounter: test_order }
  let(:default_params)    { { context: institution.uuid } }

  describe 'filename' do
    subject { described_class.new(Encounter.all.order(:created_at), 'test.thecdx.org').filename }

    it 'should include the hostname in file' do
      expect(subject).to include 'test.thecdx.org_test_orders_status'
    end
  end

  describe 'export_all' do
    subject { described_class.new(Encounter.all.order(:created_at), 'test.thecdx.org').export_all }

    before :each do
      User.current = user
      TestOrders::Status.update_and_log(test_order, 'samples_collected')
      TestOrders::Status.update_and_log(test_order, 'allocated')
    end

    it 'should return an array of test order status updates' do
      csv = CSV.parse(subject)
      expect(csv[0]).to eq(['Order ID', 'Previous state', 'Current state', 'Date', 'Patient ID'])
      expect(csv[1]).to eq(
        [
          test_order.batch_id,
          'new',
          'samples_collected',
          Extras::Dates::Format.datetime_with_time_zone(test_order.created_at, :full_time_with_timezone),
          test_order.patient.id.to_s
        ]
      )
    end
  end

  describe 'export_one' do
    subject { described_class.new(test_order, 'test.thecdx.org').export_one }

    before :each do
      User.current = user
      PatientResults::StatusAuditor.create_status_log(microscopy_result, %w(new pending_approval))
      PatientResults::StatusAuditor.create_status_log(microscopy_result, %w(pending_approval rejected))
      microscopy_result.reload
    end

    it 'should return an array of patient results status update' do
      csv = CSV.parse(subject)
      expect(csv[0]).to eq(['Order ID', 'Sample ID', 'Previous state', 'Current state', 'Date', 'Patient ID'])
      expect(csv[1]).to eq(
        [
          test_order.batch_id,
          microscopy_result.serial_number,
          'new',
          'pending_approval',
          Extras::Dates::Format.datetime_with_time_zone(test_order.created_at, :full_time_with_timezone),
          test_order.patient.id.to_s
        ]
      )
    end
  end
end
