module Notifications
  module Aggregation
    class Weekly < Notifications::Aggregation::Base
      def notices_by_user
        @notices_by_user ||=
          Notification::Notice.pending.includes(:notification)
                              .where('notification_notices.created_at < ?', triggered_at)
                              .where(notifications: { frequency: 'aggregate', frequency_value: 'weekly' })
                              .order('notification_notices.created_at DESC')
                              .group_by { |notice| notice.notification.user }
      end

      def notices
        # Trigger at 8am on Monday in the creating users timezone
        @notices ||=
          notices_by_user
            .select do |user, _grouped_notices|
              triggered_at.in_time_zone(user.time_zone).hour == 8 &&
              triggered_at.in_time_zone(user.time_zone).wday == 1
            end.map { |_user, grouped_notices| grouped_notices }.flatten.uniq
      end
    end
  end
end
