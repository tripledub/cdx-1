
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
  end
end
