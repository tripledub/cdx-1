# Dashboard controller
class DashboardsController < ApplicationController
  before_action :set_filter_params, only: [:index]

  def index
    @institution_name = @navigation_context.name if @navigation_context.try(:entity)
    @dashboard_report = Reports::Dashboard.new(current_user, @navigation_context, options)
  end

  def nndd
    return unless authorize_resource(TestResult, MEDICAL_DASHBOARD)
  end

  protected

  def options
    params.delete('range') if params['range'] && params['range']['start_time']['lte'].empty?
    params.delete('range') if params['range'] && params['range']['start_time']['gte'].empty?
    return { 'date_range' => params['range'] } if params['range']
    return { 'since' => params['since'] } if params['since']
    {}
  end

  def set_filter_params
    set_filter_from_params(FilterData::Dashboard)
  end
end
