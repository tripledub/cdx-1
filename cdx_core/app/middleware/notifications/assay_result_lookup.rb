module Notifications
  class AssayResultLookup < Notifications::BaseLookup
    def check_notifications
      return [] if alertable.assayable.blank?
      return [] if alertable.condition.blank? &&
                   alertable.result.blank?    &&
                   alertable.quantitative_result.blank?

      @notifications =
        Notification.enabled
                    .includes(:institution, :sites, :notification_statuses, :patient)
                    .where(institutions: { id: alertable.assayable.institution_id })
                    .where('sites.id is null OR sites.id = ?', alertable.assayable.site_id)

      if alertable.assayable.patient
        @notifications = @notifications.where('patients.id is null OR patients.id = ?', alertable.assayable.patient.id)
      end

      if alertable.assayable.encounter
        @notifications = @notifications.where('notification_statuses.id is null OR notification_statuses.test_status = ?', alertable.assayable.encounter.status)
      else
        @notifications = @notifications.where('notification_statuses.id is null')
      end

      if alertable.condition
        @notifications =
          @notifications.where('notifications.detection is null OR notifications.detection = ?', alertable.condition)
      else
        @notifications = @notifications.where('notifications.detection is null')
      end

      if alertable.result
        @notifications =
          @notifications.where('notifications.detection_condition is null OR notifications.detection_condition = ?', alertable.result)
      else
        @notifications = @notifications.where('notifications.detection_condition is null')
      end

      if alertable.quantitative_result
        @notifications =
          @notifications.where('notifications.detection_quantitative_result is null OR notifications.detection_quantitative_result = ?', alertable.quantitative_result)
      else
        @notifications = @notifications.where('notifications.detection_quantitative_result is null')
      end
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(AssayResult.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
