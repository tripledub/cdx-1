module Notifications
  class CultureResultLookup < Notifications::PatientResultLookup
    def check_notifications
      super
      # Find notifications that don't have any conditions, or
      # Find notifications that have a matching CultureResult#result_status, or
      # Find notifications that have a matching CultureResult#media_user, or
      # Find notifications that have a matching CultureResult#test_result, or

      @notifications =
        @notifications.where(%{notification_conditions.id is null OR
                              (notification_conditions.condition_type = \'CultureResult\' AND
                               notification_conditions.field = \'result_status\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'CultureResult\' AND
                               notification_conditions.field = \'media_used\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'CultureResult\' AND
                               notification_conditions.field = \'test_result\' AND
                               notification_conditions.value = ?)
                            }, alertable.result_status,
                               alertable.media_used,
                               alertable.test_result)

      # {"result_status"=>[nil, "completed"], "media_used"=>[nil, "solid"], "test_result"=>[nil, "contaminated"]}
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(CultureResult.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
