module Notifications
  class DstLpaResultLookup < Notifications::PatientResultLookup
    def check_notifications
      super
      # TODO: Currently Notification needs support added. Additions need
      # to be made to Notification model to accept more results
      # not just 'detection', 'detection_condition'.
      # DstLpaResult notify on `media_used`,
      #                 `method_used`, `results_h`,
      #                 `results_r`, `results_e`,
      #                 `results_s`, `results_amk`,
      #                 `results_km`, `results_cm`,
      #                 `results_fq`, `results_other1`
      # From job example:
      # {"media_used"=>[nil, "solid"], "method_used"=>[nil, "direct"],
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
