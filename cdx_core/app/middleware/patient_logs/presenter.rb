module PatientLogs
  # PatientLogs Presenter
  class Presenter
    class << self
      def patient_view(patient_logs)
        log_data = {}
        log_data['rows'] = get_patient_info(patient_logs)
        log_data['pages'] = {
          total_pages: patient_logs.total_pages,
          current_page: patient_logs.current_page,
          first_page: patient_logs.first_page?,
          last_page: patient_logs.last_page?,
          prev_page: patient_logs.prev_page,
          next_page: patient_logs.next_page
        }
        log_data
      end

      protected

      def get_patient_info(patient_logs)
        patient_logs.map do |log|
          {
            id:       log.uuid,
            date:     I18n.l(log.created_at, format: :short),
            user:     logged_user(log),
            device:   logged_device(log),
            title:    Audit::TextTranslator.localise(log.title),
            viewLink: Rails.application.routes.url_helpers.patient_patient_log_path(log.patient, log)
          }
        end
      end

      def logged_user(log)
        log.user.full_name if log.user.present?
      end

      def logged_device(log)
        log.device.full_name if log.device.present?
      end
    end
  end
end
