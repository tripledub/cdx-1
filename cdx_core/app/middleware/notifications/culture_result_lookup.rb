module Notifications
  class CultureResultLookup < Notifications::BaseLookup
    def check_notifications
      # TODO: Currently Notification needs support added. Additions need
      # to be made to Notification model to accept more results
      # not just 'detection', 'detection_condition'.
      # CultureResult notify on `media_used`, and `test_result`
      # From job example:
      # {"media_used"=>[nil, "solid"], "test_result"=>[nil, "contaminated"]}
      @notifications = []
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(CultureResult.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
