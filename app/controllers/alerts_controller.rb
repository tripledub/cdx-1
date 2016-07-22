class AlertsController < ApplicationController
  respond_to :html, :json

  def index
    @can_create = has_access?(Alert, CREATE_ALERT)
    @alerts = check_access(Alert, READ_ALERT)
    @alerts = @alerts.within(@navigation_context.entity, @navigation_context.exclude_subsites)
    @total = @alerts.count
    respond_with @total
  end

end
