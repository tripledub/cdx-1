
module Reports
  # Report generator class
  class Dashboard
    def initialize(current_user, navigation_context, params)
      @current_user = current_user
      @navigation_context = navigation_context
      @params = params
    end

    def total_tests
      Reports::AllTests.new(@navigation_context, @params.dup).generate_chart
    end

    def failed_tests
      Reports::Failed.new(@navigation_context, @params.dup).generate_chart
    end

    def daily_order_status
      Reports::DailyOrderStatus.new(@navigation_context, @params.dup).generate_chart
    end

    def query_site_tests
      Reports::Site.new(@current_user, @navigation_context, @params.dup).generate_chart
    end

    def outstanding_orders
      Reports::OutstandingOrders.process(@current_user, @navigation_context, @params.dup).latest_encounter
    end

    def average_test_per_site
      Reports::AverageSiteTests.new(@current_user, @navigation_context, @params.dup).generate_chart
    end

    def total_tests_by_device
      Reports::Grouped.new(@current_user, @navigation_context, @params.dup).by_device
    end

    def average_tests_per_technician
      Reports::AverageTechnicianTests.new(@current_user, @navigation_context, @params.dup).generate_chart
    end

    def devices_not_responding
      Reports::DevicesNotReporting.new(@current_user, @navigation_context, @params.dup).generate_chart
    end

    def error_codes_by_device
      data = Reports::DeviceErrorCodes.process(@current_user, @navigation_context, @params.dup)
      data.get_device_location_details
    end

    def drtb_percentage
      Reports::DrtbPercentage.new(@current_user, @navigation_context, @params.dup).generate_chart
    end

    def drug_resistance
      Reports::DrugPercentage.new(@current_user, @navigation_context, @params.dup).generate_chart
    end
  end
end
