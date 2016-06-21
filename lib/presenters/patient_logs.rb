class Presenters::PatientLogs
  class << self
    def patient_view(patient_logs)
      patient_logs.map do |log|
        {
          id:        log.uuid,
          date:      log.created_at.strftime(I18n.t('date.input_format.pattern')),
          user:      log.user.full_name,
          title:     log.title,
          view_link: Rails.application.routes.url_helpers.patient_patient_log_path(log.patient, log)
        }
      end
    end
  end
end
