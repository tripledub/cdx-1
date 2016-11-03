module Notifications
  class XpertResultLookup < Notifications::PatientResultLookup
    def check_notifications
      super
      # Find notifications that don't have any conditions, or
      # Find notifications that have a matching XpertResult#result_status, or
      # Find notifications that have a matching XpertResult#tuberculosis, or
      # Find notifications that have a matching XpertResult#rifampicin, or
      # Find notifications that have a matching XpertResult#trace, or

      @notifications =
        @notifications.where(%{notification_conditions.id is null OR
                              (notification_conditions.condition_type = \'XpertResult\' AND
                               notification_conditions.field = \'result_status\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'XpertResult\' AND
                               notification_conditions.field = \'tuberculosis\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'XpertResult\' AND
                               notification_conditions.field = \'rifampicin\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'XpertResult\' AND
                               notification_conditions.field = \'trace\' AND
                               notification_conditions.value = ?)
                            }, alertable.result_status,
                               alertable.tuberculosis,
                               alertable.rifampicin,
                               alertable.trace)

      # {"result_status"=>[nil, "completed"],  {"tuberculosis"=>[nil, "detected"], "rifampicin"=>[nil, "not_detected"], "trace"=>[nil, "high"]}
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(XpertResult.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
