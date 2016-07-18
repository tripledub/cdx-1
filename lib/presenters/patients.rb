class Presenters::Patients
  class << self
    include PatientsHelper

    def index_table(patients)
      patients.map do |patient|
        {
          id:             patient.uuid,
          name:           patient_display_name(patient.name),
          entityId:       patient.entity_id,
          dateOfBirth:    Extras::Dates::Format.datetime_with_time_zone(patient.dob),
          address:        show_full_address(patient),
          lastEncounter:  Extras::Dates::Format.datetime_with_time_zone(patient.last_encounter),
          viewLink:       Rails.application.routes.url_helpers.patient_path(patient)
        }
      end
    end

    def show_full_address(patient)
      return '' unless patient.addresses.present?

      patient_address = patient.addresses.first
      address = []
      address << patient_address.address
      address << patient_address.city
      address << patient_address.state
      address << patient_address.zip_code
      address.reject(&:blank?).join(', ')
    end
  end
end
