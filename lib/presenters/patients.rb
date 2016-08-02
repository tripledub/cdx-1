class Presenters::Patients
  class << self
    include PatientsHelper

    def index_table(patients)
      patients.map do |patient|
        {
          id:             patient.uuid,
          name:           patient_display_name(patient.name),
          entityId:       patient.entity_id,
          dateOfBirth:    Extras::Dates::Format.datetime_with_time_zone(patient.birth_date_on),
          addresses:      show_first_address(patient),
          viewLink:       Rails.application.routes.url_helpers.patient_path(patient)
        }
      end
    end

    def show_full_address(patient_address)
      return '' unless patient_address.present?

      address = []
      address << patient_address.address
      address << patient_address.city
      address << patient_address.state
      address << patient_address.zip_code
      address.reject(&:blank?).join(', ')
    end

    protected

    def show_first_address(patient)
      return '' unless patient.addresses.present?
      patient.addresses.map do |address|
        show_full_address(address)
      end.compact.reject(&:blank?)
    end
  end
end
