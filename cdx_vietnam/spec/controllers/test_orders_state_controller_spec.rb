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

  describe 'patients' do
    it 'should return a CSV file with patients information' do
      get :patients, format: :csv
      csv = CSV.parse(response.body)

      expect(csv[0]).to eq(
        [
          'Patient ID',
          'Date of creation',
          'Site ID',
          'ETB Patient ID',
          'VITIMES Patient ID',
          'CMND',
          'VITIMES/ETB Manager log ID',
          'External ID',
          'Gender',
          'Address',
          'Nationality'
        ]
      )
      expect(csv[1]).to eq(
        [
          patient.id.to_s,
          Extras::Dates::Format.datetime_with_time_zone(patient.created_at, :full_time_with_timezone),
          site.id.to_s,
          patient.etb_patient_id.to_s,
          patient.vtm_patient_id.to_s,
          patient.social_security_code,
          patient.entity_id.to_s,
          patient.external_id.to_s,
          patient.gender,
          Patients::Presenter.show_full_address(patient.addresses[0]),
          patient.nationality
        ]
      )
    end
  end
end
