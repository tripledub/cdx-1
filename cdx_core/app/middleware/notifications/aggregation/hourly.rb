module Notifications
  module Aggregation
    class Hourly < Notifications::Aggregation::Base
      def notices_by_notification
        @notices_by_notification ||= begin
          @notices =
            Notification::Notice.pending.includes(:notification)
                                .where('notification_notices.created_at < ?', triggered_at)
                                .where(notifications: { frequency: frequency, frequency_value: frequency_value })
                                .order('notification_notices.created_at DESC')
          @notices.group_by(&:notification)
        end
      end
    end
  end
end
