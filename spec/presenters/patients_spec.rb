require 'spec_helper'

describe Presenters::Patients do
  include PatientsHelper
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }

  describe 'patient_view' do
    before :each do
      7.times {
        address = Address.make
        Patient.make institution: institution, addresses: [address]
      }
    end

    it 'should return an array of formated comments' do
      expect(Presenters::Patients.index_table(institution.patients).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(Presenters::Patients.index_table(institution.patients).first).to eq({
        id:             Patient.first.uuid,
        name:           patient_display_name(Patient.first.name),
        entityId:       Patient.first.entity_id,
        dateOfBirth:    Extras::Dates::Format.datetime_with_time_zone(Patient.first.dob),
        address:        "#{Patient.first.addresses.first.address}, #{Patient.first.addresses.first.city}, #{Patient.first.addresses.first.state}, #{Patient.first.addresses.first.zip_code}",
        lastEncounter:  Extras::Dates::Format.datetime_with_time_zone(Patient.first.last_encounter),
        viewLink:       Rails.application.routes.url_helpers.patient_path(Patient.first)
      })
    end
  end

  describe 'show_full_address' do
    it 'should display the full address of a patient' do
      address = Address.make
      patient = Patient.make institution: institution, addresses: [address]

      described_class.show_full_address(patient).should eq("#{address.address}, #{address.city}, #{address.state}, #{address.zip_code}")
    end

    it 'should not display the commas if any field is empty' do
      address = Address.make address: '', state: ''
      patient = Patient.make institution: institution, addresses: [address]

      described_class.show_full_address(patient).should eq("#{address.city}, #{address.zip_code}")
    end
  end
end
