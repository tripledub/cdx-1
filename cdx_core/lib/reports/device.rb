module Reports
  # Device charts
  class Device
    def initialize(current_user, navigation_context, options)
      @current_user       = current_user
      @navigation_context = navigation_context
      @options            = options
    end

    def total_tests
      Reports::AllTests.new(@navigation_context, @options.dup).generate_chart
    end

    def failed_tests
      Reports::Failed.new(@navigation_context, @options.dup).generate_chart
    end
  end
end
