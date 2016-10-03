module Notifications
  class TestResultLookup < Notifications::BaseLookup
    def check_notifications
      # TODO: Currently Notification needs support added. Additions need
      # to be made to Notification model to accept more results
      # not just 'detection', 'detection_condition'.
      # These are only used for devices, device notifications-
      # *for now* happen at the AssayResult level.
      @notifications = []
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(TestResult.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
