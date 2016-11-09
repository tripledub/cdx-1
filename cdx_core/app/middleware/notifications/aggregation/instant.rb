module Notifications
  module Aggregation
    class Instant < Notifications::Aggregation::Base
      def notices
        @notices ||=
          Notification::Notice.pending.includes(:notification)
                              .where('notification_notices.created_at < ?', triggered_at)
                              .where(notifications: { frequency: 'instant' })
                              .order('notification_notices.created_at DESC')
      end
    end
  end
end
