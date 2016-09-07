class Reports::Device
  def initialize(current_user, navigation_context, options)
    @current_user       = current_user
    @navigation_context = navigation_context
    @options            = options
  end

  def total_tests
    Reports::AllTests.new(@current_user, @navigation_context, @options).generate_chart
  end

  def failed_tests
    Reports::Failed.new(@current_user, @navigation_context, @options).generate_chart
  end

  def error_codes_by_device
    data = Reports::DeviceErrorCodes.process(@current_user, @navigation_context, @options)
    data.get_device_location_details
  end
end
