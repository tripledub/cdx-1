module Notifications
  class MicroscopyResultLookup < Notifications::BaseLookup
    def check_notifications
      # TODO: Currently Notification needs support added. Additions need
      # to be made to Notification model to accept more results
      # not just 'detection', 'detection_condition'.
      # MicroscopyResult notify on `appearance`, `specimen_type`, `test_result`
      # From job example:
      # {"appearance"=>[nil, "blood"],
      #  "specimen_type"=>[nil, "some type"],
      #  "test_result"=>[nil, "1to9"]}
      @notifications = []
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(MicroscopyResult.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
