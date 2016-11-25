module Notifications
  class AssayResultLookup < Notifications::BaseLookup
    def check_notifications
      return [] if alertable.assayable.blank?
      return [] if alertable.condition.blank? &&
                   alertable.result.blank?    &&
                   alertable.quantitative_result.blank?

      @notifications =
        Notification.enabled
                    .includes(:institution, :sites, :notification_conditions, :patient)
                    .where(institutions: { id: alertable.assayable.institution_id })
                    .where('sites.id is null OR sites.id = ?', alertable.assayable.site_id)

      if alertable.assayable.patient
        @notifications = @notifications.where('patients.id is null OR patients.id = ?', alertable.assayable.patient.id)
      end

      # Find notifications that don't have any conditions, or
      # Find notifications that have a matching AssayResult#condition, and
      # Find notifications that have a matching AssayResult#result, and
      # Find notifications that have a matching AssayResult#quantitative_result, and

      conditions = if alertable.condition.present?
        @notifications.where(%{notification_conditions.condition_type = \'AssayResult\' AND
                               notification_conditions.field = \'condition\' AND
                               notification_conditions.value = ?}, alertable.condition)
      end || []

      results = if alertable.result.present?
        @notifications.where(%{notifications.id in (?) AND
                               notification_conditions.condition_type = \'AssayResult\' AND
                               notification_conditions.field = \'result\' AND
                               notification_conditions.value = ?}, conditions.map(&:id), alertable.result)
      end || []

      quantitative_results = if alertable.quantitative_result.present?
        @notifications.where(%{notifications.id in (?) AND
                               notification_conditions.condition_type = \'AssayResult\' AND
                               notification_conditions.field = \'quantitative_result\' AND
                               notification_conditions.value = ?}, results.map(&:id), alertable.quantitative_result)
      end || []

      @notifications = @notifications.where('notifications.id in (?) OR notification_conditions.id is null', quantitative_results.map(&:id))
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(AssayResult.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
