module Patients
  # Export patient info into CSV mode
  class ListCsv
    attr_reader :filename

    def initialize(patients)
      @patients = patients
    end

    def filename
      @filename || "#{@hostname}_patients_-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
    end

    def export
      CSV.generate do |csv|
        csv << [
          I18n.t('patients.csv_export.patient_id'),
          I18n.t('patients.csv_export.created_at'),
          I18n.t('patients.csv_export.site_id'),
          I18n.t('patients.csv_export.etb_patient_id'),
          I18n.t('patients.csv_export.vtm_patient_id'),
          I18n.t('patients.csv_export.social_security_code'),
          I18n.t('patients.csv_export.entity_id'),
          I18n.t('patients.csv_export.external_id'),
          I18n.t('patients.csv_export.gender'),
          I18n.t('patients.csv_export.address'),
          I18n.t('patients.csv_export.nationality')

        ]
        @patients.map { |patient| add_patient(csv, patient) }
      end
    end

    protected

    def add_patient(csv, patient)
      csv << [
        patient.id.to_s,
        Extras::Dates::Format.datetime_with_time_zone(patient.created_at, :full_time),
        patient.site.id.to_s,
        patient.etb_patient_id.to_s,
        patient.vtm_patient_id.to_s,
        patient.social_security_code,
        patient.entity_id.to_s,
        patient.external_id.to_s,
        patient.gender,
        Patients::Presenter.show_full_address(patient.addresses[0]),
        patient.nationality
      ]
    end
  end
end
