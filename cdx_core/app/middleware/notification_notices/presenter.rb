module NotificationNotices
  class Presenter
    class << self
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::DateHelper
      include NotificationNoticesHelper

      def index_table(notification_notices)
        notification_notices.map do |notification_notice|
          {
            id:           notification_notice.id,
            notification: truncate(notification_notice.notification.name, length: 20),
            date:         Extras::Dates::Format.datetime_with_time_zone(notification_notice.created_at),
            status:       notification_notice.status,
            message:      friendly_data(notification_notice.data),
            viewLink:     Rails.application.routes.url_helpers.edit_alert_group_path(notification_notice.notification)
          }
        end
      end
    end
  end
end
