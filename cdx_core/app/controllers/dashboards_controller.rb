# Dashboard controller
class DashboardsController < ApplicationController
  before_action :set_filter_params, only: [:index]

  def index
    @institution_name = @navigation_context.name if @navigation_context.try(:entity)
    @dashboard_report = Reports::Dashboard.new(current_user, @navigation_context, params)
  end

  def nndd
    return unless authorize_resource(TestResult, MEDICAL_DASHBOARD)
  end

  protected

  def set_filter_params
    set_filter_from_params(FilterData::Dashboard)
  end
end
