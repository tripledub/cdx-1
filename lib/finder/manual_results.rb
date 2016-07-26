class Finder::ManualResults
  attr_reader :params, :filter_query

  def initialize(params, navigation_context)
    @params             = params
    @navigation_context = navigation_context
    @filter_query       = set_filter
    apply_filters
  end

  protected

  def results_class
    raise NoMethodError
  end

  def set_filter
    results_class.joins('LEFT OUTER JOIN requested_tests ON requested_tests.id = patient_results.requested_test_id')
      .joins('LEFT OUTER JOIN encounters ON encounters.id = requested_tests.encounter_id')
      .joins('LEFT OUTER JOIN institutions ON institutions.id = encounters.institution_id')
      .joins('LEFT OUTER JOIN sites ON sites.id = encounters.site_id')
  end

  def apply_filters
    filter_by_navigation_context
    filter_by_test_result
    filter_by_sample
    filter_by_date
    filter_by_media
  end

  def filter_by_sample
    @filter_query = filter_query.where("patient_results.serial_number like'%?%'", params["sample.id"]) if params["sample.id"].present?
  end

  def filter_by_media
    @filter_query = filter_query.where('patient_results.media_used = ?', params['media']) if params['media'].present?
  end

  def filter_by_date
    since_day = start_date + ' 00:00'
    until_day = end_date + ' 23:59'
    @filter_query = filter_query.where({ 'patient_results.created_at' => since_day..until_day })
  end

  def filter_by_test_result
    @filter_query = filter_query.where('patient_results.test_result = ?', params['test_result']) if params['test_result'].present?
  end

  def start_date
    if params["since"].present?
      params['since']
    elsif params["from_date"].present?
      params['from_date']
    else
      7.days.ago.strftime("%Y-%m-%d")
    end
  end

  def end_date
    params["to_date"].present? ? params["to_date"] : Date.today.strftime("%Y-%m-%d")
  end

  def filter_by_navigation_context
    @filter_query = filter_query.where('institutions.uuid = ?', @navigation_context.institution.uuid) if @navigation_context.institution

    if @navigation_context.exclude_subsites && @navigation_context.site
      @filter_query = filter_query.where('sites.uuid = ?', @navigation_context.site.uuid)
    elsif !@navigation_context.exclude_subsites && @navigation_context.site
      # site.path is used in order to select entitites of descending sites also
      # @filter["site.path"] = @navigation_context.site.uuid
    end
  end
end
