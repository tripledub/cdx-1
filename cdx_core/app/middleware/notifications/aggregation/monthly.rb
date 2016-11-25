module Notifications
  module Aggregation
    class Monthly < Notifications::Aggregation::Base
      def notices_by_user
        @notices_by_user ||=
          Notification::Notice.pending.includes(:notification)
                              .where('notification_notices.created_at < ?', triggered_at)
                              .where(notifications: { frequency: frequency, frequency_value: frequency_value })
                              .order('notification_notices.created_at DESC')
                              .group_by { |notice| notice.notification.user }
      end

      def notices
        # Trigger at 8am on the 1st of the month in the creating users timezone
        # We don't need to check the month, it runs on a monthly cron.
        @notices ||=
          notices_by_user
            .select { |user, _grouped_notices| triggered_at.in_time_zone(user.time_zone).hour == 8 }
            .map { |_user, grouped_notices| grouped_notices }.flatten.uniq
      end
    end
  end
end
