module Notifications
  class MicroscopyResultLookup < Notifications::PatientResultLookup
    def check_notifications
      super
      # Find notifications that don't have any conditions, or
      # Find notifications that have a matching MicroscopyResult#result_status, or
      # Find notifications that have a matching MicroscopyResult#appearance, or
      # Find notifications that have a matching MicroscopyResult#specimen_type, or
      # Find notifications that have a matching MicroscopyResult#test_result, or

      @notifications =
        @notifications.where(%{notification_conditions.id is null OR
                              (notification_conditions.condition_type = \'MicroscopyResult\' AND
                               notification_conditions.field = \'result_status\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'MicroscopyResult\' AND
                               notification_conditions.field = \'appearance\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'MicroscopyResult\' AND
                               notification_conditions.field = \'specimen_type\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'MicroscopyResult\' AND
                               notification_conditions.field = \'test_result\' AND
                               notification_conditions.value = ?)
                            }, alertable.result_status,
                               alertable.appearance,
                               alertable.specimen_type,
                               alertable.test_result)

      # {"result_status"=>[nil, "completed"], "appearance"=>[nil, "blood"],
      #  "specimen_type"=>[nil, "some type"],
      #  "test_result"=>[nil, "1to9"]}
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(MicroscopyResult.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
