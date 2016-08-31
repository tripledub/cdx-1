class Presenters::PatientSearch
  class << self
    include PatientsHelper

    def search_results(patients)
      patients.map do |patient|
        {
          id:        patient.uuid,
          birthDate: Extras::Dates::Format.patient_birth_date(patient.birth_date_on),
          name:      patient_display_name(patient.name),
          gender:    patient.gender,
          viewLink:  Rails.application.routes.url_helpers.patient_path(patient)
        }
      end
    end
  end
end
