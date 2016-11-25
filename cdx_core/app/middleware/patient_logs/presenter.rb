module PatientLogs
  # PatientLogs Presenter
  class Presenter
    class << self
      def patient_view(patient_logs, order_by)
        log_data = {}
        log_data['rows'] = get_patient_info(patient_logs)
        log_data['pages'] = {
          totalPages: patient_logs.total_pages,
          currentPage: patient_logs.current_page,
          firstPage: patient_logs.first_page?,
          lastPage: patient_logs.last_page?,
          prevPage: patient_logs.prev_page,
          nextPage: patient_logs.next_page
        }
        log_data['order_by'] = order_by
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
