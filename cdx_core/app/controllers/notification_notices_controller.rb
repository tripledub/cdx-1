class NotificationNoticesController < ApplicationController
  respond_to :html, :json

  def index
    if has_access?(Alert, READ_ALERT)
      @notification_notices  = current_user.notification_notices
      @total                 = @notification_notices.count
      order_by, offset = perform_pagination('notification_notices.created_at DESC')
      @notification_notices  = @notification_notices.includes(:notification).order(order_by).limit(@page_size).offset(offset)
    else
      @notification_notices = []
    end
  end
end
