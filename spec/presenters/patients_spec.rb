require 'spec_helper'

describe Presenters::Patients do
  include PatientsHelper
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }

  describe 'patient_view' do
    before :each do
      7.times { Patient.make institution: institution }
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
        address:        "#{Patient.first.address}, #{Patient.first.city}, #{Patient.first.state}, #{Patient.first.zip_code}",
        lastEncounter:  Extras::Dates::Format.datetime_with_time_zone(Patient.first.last_encounter),
        viewLink:       Rails.application.routes.url_helpers.patient_path(Patient.first)
      })
    end
  end

  describe 'show_full_address' do
    it 'should display the full address of a patient' do
      patient = Patient.make institution: institution

      described_class.show_full_address(patient).should eq("#{patient.address}, #{patient.city}, #{patient.state}, #{patient.zip_code}")
    end

    it 'should not display the commas if any field is empty' do
      patient = Patient.make institution: institution, address: '', state: ''

      described_class.show_full_address(patient).should eq("#{patient.city}, #{patient.zip_code}")
    end
  end
end
