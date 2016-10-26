class AlertsController < ApplicationController
  respond_to :html, :json

  def index
    @can_create = has_access?(Notification, CREATE_NOTIFICATION)
    @notifications = check_access(Notification, READ_NOTIFICATION)
    @notifications = @notifications.within(@navigation_context.entity, @navigation_context.exclude_subsites)
    @total = @notifications.enabled.count
    respond_with @total
  end

end
