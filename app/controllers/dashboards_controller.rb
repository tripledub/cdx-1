class DashboardsController < ApplicationController
  def index;
  	@institution_name = @navigation_context.name if @navigation_context.try(:entity)
    @total_tests_char = Reports::AllTests.new(current_user, @navigation_context, { title: 'Graph title', titleY: 'Y title', titleY2: 'Y2 Title' }).generate_chart
  end

  def nndd
    return unless authorize_resource(TestResult, MEDICAL_DASHBOARD)
  end
end
