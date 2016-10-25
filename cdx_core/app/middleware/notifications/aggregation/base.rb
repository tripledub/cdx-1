module Notifications
  module Aggregation
    class Base
      attr_reader   :triggered_at
      attr_accessor :notices, :frequency, :frequency_value

      def initialize(triggered_at = Time.now)
        @triggered_at = triggered_at
        @notices = []
        !self.class.is_a?(Notifications::Aggregation::Targeted) &&
          @frequency_value = self.class.to_s.downcase.split('::').last
        @frequency = @frequency_value ? 'aggregate' : 'targeted'
      end

      def notices_by_notification
        raise Notifications::Error::NotImplemented
      end

      def latest_notices
        @latest_notices ||=
          notices_by_notification.map { |_notification, grouped_notices| grouped_notices.first }
      end

      def notice_ids
        @notice_ids ||= @notices.map(&:id)
      end

      def latest_notice_ids
        @latest_notice_ids ||= latest_notices.map(&:id)
      end

      def distinct_emails_with_count
        # Returns a format like {"test@example.com"=>2, "test2@example.com"=>1}
        # Will return {nil => 2} where 2 is number of notifications if there are no delivery methods.
        @distinct_emails_with_count ||=
          Notification::NoticeRecipient.where(notifications: { email: true })
                                       .where(notification_notices: { id: notice_ids })
                                       .includes(:notification_notice => :notification)
                                       .select(:email, :notification_id)
                                       .group(:email)
                                       .count(:notification_notice_id)
      end

      def distinct_telephones_with_count
        # Returns a format like {"+441234566789"=>2, "+4412345662222"=>1}
        # Will return {nil => 2} where 2 is number of notifications if there are no delivery methods.
        @distinct_telephones_with_count ||=
          Notification::NoticeRecipient.where(notifications: { sms: true })
                                       .where(notification_notices: { id: notice_ids })
                                       .includes(:notification_notice => :notification)
                                       .select(:telephone, :notification_id)
                                       .group(:telephone)
                                       .count(:notification_notice_id)
      end

      def defer_redundant_notices!
        Notification::Notice.where(id: notice_ids)
                            .where.not(id: latest_notice_ids)
                            .update_all(status: 'deferred')
      end

      def process
        return if latest_notices.empty?

        notices.map(&:create_recipients)

        notice_group = Notification::NoticeGroup.new(
          notification_notice_ids: latest_notice_ids,
          frequency: frequency,
          frequency_value: frequency_value,
          triggered_at: triggered_at
        )

        notice_group.email_data     = distinct_emails_with_count
        notice_group.telephone_data = distinct_telephones_with_count

        defer_redundant_notices!

        notice_group.save!

        true
      end

      def self.run
        new(Time.now)
          .process
      end
    end
  end
end
