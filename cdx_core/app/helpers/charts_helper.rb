module ChartsHelper
  def devices_reporting_chart
    results = Reports::Devices.process(current_user, @navigation_context, options)
    return results.sort_by_month if results.number_of_months > 1
    results.sort_by_day
  end

  def errors_by_code
    Reports::Grouped.by_error_code(current_user, @navigation_context, options)
  end

  def error_codes_by_device
    data = Reports::DeviceErrorCodes.process(current_user, @navigation_context, options)
    data.get_device_location_details
  end

  def errors_by_device_chart
    results = Reports::DeviceErrors.process(current_user, @navigation_context, options)
    return results.sort_by_month if results.number_of_months > 1
    results.sort_by_day
  end

  def errors_by_model_chart
    results = Reports::ModelErrors.process(current_user, @navigation_context, options)
    return results.sort_by_month if results.number_of_months > 1
    results.sort_by_day
  end

  def errors_by_model
    Reports::Grouped.by_model(current_user, @navigation_context, options)
  end

  def successful_tests_chart
    results = Reports::Successful.process(current_user, @navigation_context, options)
    return results.sort_by_month if results.number_of_months > 1
    results.sort_by_day
  end

  def unsuccessful_tests_chart
    options['test.status'] = 'invalid,error,no_result,in_progress'
    results = Reports::Unsuccessful.process(current_user, @navigation_context, options)
    return results.sort_by_month if results.number_of_months > 1
    results.sort_by_day
  end

  def successful_tests
    Reports::Grouped.by_successful(current_user, @navigation_context, options)
  end

  def unsuccessful_tests
    Reports::Grouped.by_unsuccessful(current_user, @navigation_context, options)
  end

  def errors_by_not_successful
    Reports::Grouped.by_unsuccessful(current_user, @navigation_context, options)
  end

  def chart_heading
    stdate = start_date.strftime('%a %d %b %Y')
    endate = end_date.strftime('%a %d %b %Y')
    if days_since <= 7
      message = "in the previous #{days_since} days"
    else
      message = "between #{stdate} and #{endate}"
    end
    message
  end

  def tests_by_status
    Reports::Grouped.by_status(current_user, @navigation_context, options)
  end

  def tests_by_failed
    Reports::Grouped.by_failed(current_user, @navigation_context, options)
  end

  def days_since
    end_date.jd - start_date.jd
  end

  def number_of_months
    (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)
  end

  def start_date
    params['range']['start_time']['gte'].present? ? Date.parse(params['range']['start_time']['gte']) : since
  end

  def end_date
    params['range']['start_time']['lte'].present? ? Date.parse(params['range']['start_time']['lte']) : Date.today
  end

  def query_errors
    results = Reports::Errors.process(current_user, @navigation_context, options)
    return results.sort_by_month if results.number_of_months > 1
    results.sort_by_day
  end

  def since
    params['since'] ? Date.parse(params['since']) : Date.today - 1.year
  end
end
