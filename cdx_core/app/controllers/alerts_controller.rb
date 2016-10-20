class AlertsController < ApplicationController
  respond_to :html, :json

  def index
    @can_create = has_access?(Notification, CREATE_ALERT)
    @notifications = check_access(Notification, READ_ALERT)
    @notifications = @notifications.within(@navigation_context.entity, @navigation_context.exclude_subsites)
    @total = @notifications.enabled.count
    respond_with @total
  end

end
