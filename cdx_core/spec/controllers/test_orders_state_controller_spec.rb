require 'spec_helper'

describe TestOrdersStateController do
  let(:institution)       { Institution.make }
  let(:user)              { institution.user }
  let(:site)              { Site.make institution: institution }
  let(:patient)           { Patient.make institution: institution, site: site }
  let(:test_order)        { Encounter.make patient: patient }
  let(:microscopy_result) { MicroscopyResult.make encounter: test_order, serial_number: 'AXP-998' }
  let(:default_params)    { { context: institution.uuid } }

  before :each do
    sign_in user
    User.current = user
    TestOrders::Status.update_and_log(test_order, 'samples_received')
  end

  describe 'index' do
    it 'should return a CSV file' do
      get :index, format: :csv
      csv = CSV.parse(response.body)

      expect(csv[0]).to eq(['Order ID', 'Previous state', 'Current state', 'Date', 'Patient ID'])
      expect(csv[1]).to eq(
        [
          test_order.batch_id,
          'new',
          'samples_received',
          Extras::Dates::Format.datetime_with_time_zone(test_order.created_at, :full_time),
          test_order.patient.id.to_s
        ]
      )
    end
  end

  describe 'show' do
    before :each do
      PatientResults::StatusAuditor.create_status_log(microscopy_result, %w(new pending_approval))
      PatientResults::StatusAuditor.create_status_log(microscopy_result, %w(pending_approval rejected))
    end

    it 'should return a CSV file' do
      get :show, id: test_order.id, format: :csv
      csv = CSV.parse(response.body)

      expect(csv[0]).to eq(['Order ID', 'Sample ID', 'Previous state', 'Current state', 'Date', 'Patient ID'])
      expect(csv[1]).to eq(
        [
          test_order.batch_id,
          microscopy_result.serial_number,
          'new',
          'pending_approval',
          Extras::Dates::Format.datetime_with_time_zone(test_order.created_at, :full_time),
          test_order.patient.id.to_s
        ]
      )
    end
  end
end
