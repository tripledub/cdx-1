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
    results_class.joins('LEFT OUTER JOIN institutions ON institutions.id = patient_results.institution_id')
      .joins('LEFT OUTER JOIN sites ON sites.id = patient_results.site_id')
      .joins('LEFT OUTER JOIN sample_identifiers ON sample_identifiers.id = patient_results.sample_identifier_id')
  end

  def apply_filters
    filter_by_navigation_context
    filter_by_device
    filter_by_assays
    filter_by_test_type
    filter_by_sample
    filter_by_date
    filter_by_status
  end

  def filter_by_device
    filter_query.where('devices.uuid = ? ', params["device.uuid"]) if params["device.uuid"].present?
  end

  def filter_by_assays
    filter_query.where("patient_results.core_fields like 'condition: %?%'", params["test.assays.condition"]) if params["test.assays.condition"].present?
    filter_query.where("patient_results.core_fields like 'result: %?%'",    params["test.assays.condition"]) if params["test.assays.result"].present?
  end

  def filter_by_test_type
    filter_query.where("patient_results.core_fields like 'type: %?%'", params["test.type"]) if params["test.type"].present?
  end

  def filter_by_sample
    filter_query.where("sample_identifiers.entity_id = ? OR patient_results.serial_number like'%?%'", params["sample.id"], params["sample.id"]) if params["sample.id"].present?
  end

  def filter_by_date
    since_day = start_date + ' 00:00'
    until_day = end_date + ' 23:59'
    filter_query.where({ 'patient_results.created_at' => since_day..until_day })
  end

  def filter_by_status
    filter_query.where("patient_results.core_fields like 'status: %?%'", params["test.status"]) if params["test.status"].present?
  end

  def start_date
    params["since"] || params["from_date"] || 7.days.ago.strftime("%Y-%m-%d")
  end

  def end_date
    params["to_date"] || Date.today.strftime("%Y-%m-%d")
  end

  def filter_by_navigation_context
    filter_query.where('institutions.uuid = ?', @navigation_context.institution.uuid) if @navigation_context.institution

    if @navigation_context.exclude_subsites && @navigation_context.site
      filter_query.where('sites.uuid = ?', @navigation_context.site.uuid)
    elsif !@navigation_context.exclude_subsites && @navigation_context.site
      # site.path is used in order to select entitites of descending sites also
      # @filter["site.path"] = @navigation_context.site.uuid
    end
  end
end
