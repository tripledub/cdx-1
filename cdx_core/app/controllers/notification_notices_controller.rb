class NotificationNoticesController < ApplicationController
  respond_to :html, :json

  def index
    if has_access?(Notification, READ_NOTIFICATION)
      @notifications = check_access(Notification, READ_NOTIFICATION)
      @notifications = @notifications.within(@navigation_context.entity, @navigation_context.exclude_subsites)

      @notification_notices =
        Notification::Notice
          .joins(notification: [:notification_users])
          .where('notification_users.user_id = ? OR notifications.user_id = ? OR notifications.id IN (?)', current_user.id, current_user.id, @notifications.map(&:id))
      @total                 = @notification_notices.count
      order_by, offset = perform_pagination(table: 'notifications_notices_index', field_name: '-notification_notices.created_at')
      @notification_notices  = @notification_notices.includes(:notification).order(order_by).limit(@page_size).offset(offset)
    else
      @notification_notices = []
    end
  end
end
