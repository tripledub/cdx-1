class DashboardsController < ApplicationController
  def index;
  	@institution_name             = @navigation_context.name if @navigation_context.try(:entity)
    @total_tests                  = Reports::AllTests.new(current_user, @navigation_context, options).generate_chart
    @failed_tests                 = Reports::Failed.new(current_user, @navigation_context, options).generate_chart
    @query_site_tests             = Reports::Site.new(current_user, @navigation_context, options).generate_chart
    @outstanding_orders           = Reports::OutstandingOrders.process(current_user, @navigation_context, options).latest_encounter
    @average_test_per_site        = Reports::AverageSiteTests.new(current_user, @navigation_context, options).generate_chart
    @total_tests_by_device        = Reports::Grouped.new(current_user, @navigation_context, options).by_device
    @average_tests_per_technician = Reports::AverageTechnicianTests.new(current_user, @navigation_context, options).generate_chart
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
