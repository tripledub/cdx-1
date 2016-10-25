module Notifications
  module Aggregation
    class Daily < Notifications::Aggregation::Base
      def notices_by_user
        @notices_by_user ||=
          Notification::Notice.pending.includes(:notification)
                              .where('notification_notices.created_at < ?', triggered_at)
                              .where(notifications: { frequency: frequency, frequency_value: frequency_value })
                              .order('notification_notices.created_at DESC')
                              .group_by { |notice| notice.notification.user }
      end

      def notices_by_notification
        @notices_by_notification ||= begin
          notices_by_user.each do |user, grouped_notices|
            # Trigger at 8am in the creating users timezone
            triggered_at.in_time_zone(user.time_zone).hour == 8 &&
              @notices |= grouped_notices
          end

          @notices.group_by(&:notification)
        end
      end
    end
  end
end
