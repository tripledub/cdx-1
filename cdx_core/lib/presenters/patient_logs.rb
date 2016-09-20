class Presenters::PatientLogs
  class << self
    def patient_view(patient_logs)
      rows = patient_logs.map do |log|
        {
          id:       log.uuid,
          date:     I18n.l(log.created_at, format: :short),
          user:     log.user.full_name,
          title:    log.title,
          viewLink: Rails.application.routes.url_helpers.patient_patient_log_path(log.patient, log)
        }
      end
      log_data = {}
      log_data['rows'] = rows
      log_data['pages'] = {
        total_pages: patient_logs.total_pages,
        current_page: patient_logs.current_page,
        first_page?: patient_logs.first_page?,
        last_page?: patient_logs.last_page?,
        prev_page: patient_logs.prev_page,
        next_page: patient_logs.next_page
      }
      log_data
    end
  end
end
