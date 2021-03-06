module Notifications
  module Aggregation
    class Targeted < Notifications::Aggregation::Base
      def notices_by_user
        @notices_by_user ||=
          Notification::Notice.pending.includes(:notification)
                              .where('notification_notices.created_at < ?', triggered_at)
                              .where(notifications: { frequency: frequency })
                              .order('notification_notices.created_at DESC')
                              .group_by { |notice| notice.notification.user }
      end

      def notices
        # Trigger every day at 8am, 2pm, and 4pm in the creating users timezone
        @notices ||=
          notices_by_user
            .select do |user, _grouped_notices|
              current_hour = triggered_at.in_time_zone(user.time_zone).hour
              current_hour == 8 || current_hour == 14 || current_hour == 16
            end.map { |_user, grouped_notices| grouped_notices }.flatten.uniq
      end
    end
  end
end
