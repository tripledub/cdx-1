module Notifications
  class BaseLookup
    attr_accessor :alertable,
                  :changed_attributes,
                  :notifications,
                  :notices

    def initialize(alertable, changed_attributes = {})
      @alertable = alertable
      @changed_attributes = changed_attributes
      @notifications = []
      @notices = []
    end

    def create_notices_from_notifications
      @notices =
        Notification::Notice.create(notifications.map do |notification|
          {
            alertable: alertable,
            notification: notification,
            data: changed_attributes
          }
        end)
    end
  end
end
