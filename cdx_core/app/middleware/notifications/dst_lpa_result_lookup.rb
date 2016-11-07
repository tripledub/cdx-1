module Notifications
  class DstLpaResultLookup < Notifications::PatientResultLookup
    def check_notifications
      super
      # Find notifications that don't have any conditions, or
      # Find notifications that have a matching DstLpaResult#result_status, or
      # Find notifications that have a matching DstLpaResult#media_used, or
      # Find notifications that have a matching DstLpaResult#method_used, or
      # Find notifications that have a matching DstLpaResult#results_h, or
      # Find notifications that have a matching DstLpaResult#results_r, or
      # Find notifications that have a matching DstLpaResult#results_e, or
      # Find notifications that have a matching DstLpaResult#results_s, or
      # Find notifications that have a matching DstLpaResult#results_amk, or
      # Find notifications that have a matching DstLpaResult#results_km, or
      # Find notifications that have a matching DstLpaResult#results_cm, or
      # Find notifications that have a matching DstLpaResult#results_fq, or
      # Find notifications that have a matching DstLpaResult#results_other1, or

      @notifications =
        @notifications.where(%{notification_conditions.id is null OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'result_status\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'media_used\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'method_used\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'results_h\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'results_r\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'results_e\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'results_s\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'results_amk\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'results_km\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'results_cm\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'results_fq\' AND
                               notification_conditions.value = ?) OR
                              (notification_conditions.condition_type = \'DstLpaResult\' AND
                               notification_conditions.field = \'results_other1\' AND
                               notification_conditions.value = ?)
                            }, alertable.result_status,
                               alertable.media_used,
                               alertable.method_used,
                               alertable.results_h,
                               alertable.results_r,
                               alertable.results_e,
                               alertable.results_s,
                               alertable.results_amk,
                               alertable.results_km,
                               alertable.results_cm,
                               alertable.results_fq,
                               alertable.results_other1)

      # {"result_status"=>[nil, "completed"],  media_used"=>[nil, "solid"], "method_used"=>[nil, "direct"],
      #  "results_h"=>[nil, "resistant"], "results_r"=>[nil, "resistant"],
      #  "results_e"=>[nil, "susceptible"], "results_s"=>[nil, "contaminated"],
      #  "results_amk"=>[nil, "not_done"], "results_km"=>[nil, "contaminated"],
      #  "results_cm"=>[nil, "not_done"], "results_fq"=>[nil, "susceptible"],
      #  "results_other1"=>[nil, "Some other things"]}
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(DstLpaResult.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
