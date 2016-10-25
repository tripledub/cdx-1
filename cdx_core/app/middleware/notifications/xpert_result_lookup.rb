module Notifications
  class XpertResultLookup < Notifications::PatientResultLookup
    def check_notifications
      super

      # Currently Notification needs support added
      # TODO: notify on detection quantity
      # From job example:
      # {"tuberculosis"=>[nil, "detected"], "rifampicin"=>[nil, "not_detected"]}
      if alertable.tuberculosis == 'detected' && alertable.rifampicin == 'detected'
        @notifications =
          @notifications.where('notifications.detection is null OR notifications.detection = ? OR notifications.detection = ?', 'mtb', 'rif')
                        .where('notifications.detection_condition is null OR notifications.detection_condition = ?', 'positive')
      elsif alertable.rifampicin == 'detected'
        @notifications =
          @notifications.where('notifications.detection is null OR notifications.detection = ?', 'rif')
                        .where('notifications.detection_condition is null OR notifications.detection_condition = ?', 'positive')
      elsif alertable.tuberculosis == 'detected'
        @notifications =
          @notifications.where('notifications.detection is null OR notifications.detection = ?', 'mtb')
                        .where('notifications.detection_condition is null OR notifications.detection_condition = ?', 'positive')
      else
        @notifications = @notifications.where('notifications.detection is null')
      end
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(XpertResult.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
