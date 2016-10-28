
module Reports
  # Report generator class
  class Dashboard
    def initialize(current_user, navigation_context, params)
      @current_user = current_user
      @navigation_context = navigation_context
      @options = date_options_from_params(params)
    end

    def total_tests
      Reports::AllTests.new(@current_user, @navigation_context, @options).generate_chart
    end

    def failed_tests
      Reports::Failed.new(@current_user, @navigation_context, @options).generate_chart
    end

    def query_site_tests
      Reports::Site.new(@current_user, @navigation_context, @options).generate_chart
    end

    def outstanding_orders
      Reports::OutstandingOrders.process(@current_user, @navigation_context, @options).latest_encounter
    end

    def average_test_per_site
      Reports::AverageSiteTests.new(@current_user, @navigation_context, @options).generate_chart
    end

    def total_tests_by_device
      Reports::Grouped.new(@current_user, @navigation_context, @options).by_device
    end

    def average_tests_per_technician
      Reports::AverageTechnicianTests.new(@current_user, @navigation_context, @options).generate_chart
    end

    def devices_not_responding
      Reports::DevicesNotReporting.new(@current_user, @navigation_context, @options).generate_chart
    end

    def error_codes_by_device
      data = Reports::DeviceErrorCodes.process(@current_user, @navigation_context, @options)
      data.get_device_location_details
    end

    def drtb_percentage
      Reports::DrtbPercentage.new(@current_user, @navigation_context, @options).generate_chart
    end

    def drug_resistance
      Reports::DrugPercentage.new(@current_user, @navigation_context, @options).generate_chart
    end

    protected

    # This logic is crap. Remove when reports are refactored.
    def date_options_from_params(params)
      if params['range'].present?
        params.delete('range') if params['range']['start_time']['lte'].empty?
        params.delete('range') if params['range']['start_time']['gte'].empty?
        return { 'date_range' => params['range'] } if params['range']
      end

      return { 'since' => params['since'] } if params['since'].present?
      {}
    end
  end
end
