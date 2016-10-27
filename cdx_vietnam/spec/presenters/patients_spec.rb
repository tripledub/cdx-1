require 'spec_helper'

describe Patients::Presenter do
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
      expect(described_class.index_table(institution.patients).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.index_table(institution.patients).first).to eq({
        id:             Patient.first.uuid,
        name:           patient_display_name(Patient.first.name),
        entityId:       Patient.first.entity_id,
        dateOfBirth:    Extras::Dates::Format.datetime_with_time_zone(Patient.first.birth_date_on),
        addresses:      ["#{Patient.first.addresses.first.address}, #{Patient.first.addresses.first.city}, #{Address.regions.to_h[Patient.first.addresses.first.state]}, #{Patient.first.addresses.first.country}"],
        viewLink:       Rails.application.routes.url_helpers.patient_path(Patient.first)
      })
    end
  end

  describe 'show_full_address' do
    it 'should display the full address of a patient' do
      address = Address.make
      patient = Patient.make institution: institution, addresses: [address]

      expect(described_class.show_full_address(patient.addresses.first)).to eq("#{address.address}, #{address.city}, #{Address.regions.to_h[address.state]}, #{address.country}")
    end

    it 'should not display the commas if any field is empty' do
      address = Address.make address: nil, state: nil, country: nil
      patient = Patient.make institution: institution, addresses: [address]

      expect(described_class.show_full_address(patient.addresses.first)).to eq("#{address.city}")
    end
  end
end
