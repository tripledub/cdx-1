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
          city:           patient.city,
          lastEncounter:  Extras::Dates::Format.datetime_with_time_zone(patient.last_encounter),
          viewLink:       Rails.application.routes.url_helpers.patient_path(patient)
        }
      end
    end
  end
end
