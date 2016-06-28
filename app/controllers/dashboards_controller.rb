class DashboardsController < ApplicationController
  def index;
  	@institution_name   = @navigation_context.name if @navigation_context.try(:entity)
    @total_tests_char   = Reports::AllTests.new(current_user, @navigation_context, options).generate_chart
    @failed_tests_char  = Reports::Failed.new(current_user, @navigation_context, options).generate_chart
    @outstanding_orders = Reports::OutstandingOrders.process(current_user, @navigation_context, options).latest_encounter
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
end
