class TestResults::Finder
  attr_reader :filter_query, :params

  def initialize(navigation_context, params)
    @navigation_context = navigation_context
    @params             = params
    set_filter
  end

  protected

  def set_filter
    init_query
    filter_by_navigation_context
    filter_by_device
    filter_by_date
    filter_by_sample_identifier
  end

  def init_query
    @filter_query = TestResult.joins('LEFT OUTER JOIN institutions ON institutions.id = patient_results.institution_id')
      .joins('LEFT OUTER JOIN sites ON sites.id = patient_results.site_id')
      .joins('LEFT OUTER JOIN devices ON devices.id = patient_results.device_id')
      .joins('LEFT OUTER JOIN sample_identifiers ON sample_identifiers.id = patient_results.sample_identifier_id')
  end

  def filter_by_navigation_context
    @filter_query = filter_query.where("institutions.id = ? ", @navigation_context.institution.id) if @navigation_context.institution

    if @navigation_context.exclude_subsites && @navigation_context.site
      @filter_query = filter_query.where("sites.id = ?", @navigation_context.site.id)
    elsif !@navigation_context.exclude_subsites && @navigation_context.site
      @filter_query = filter_query.where("sites.id = ? OR sites.parent_id = ?", @navigation_context.site.id, @navigation_context.site.id)
    end
  end

  def filter_by_device
    @filter_query = filter_query.where('devices.uuid = ?', params['device_uuid']) if params['device_uuid'].present?
  end

  def filter_by_sample_identifier
    @filter_query = filter_query.where('sample_identifiers.id = ?', params['sample_id']) if params['sample_id'].present?
  end

  # def filter_by_status
  #   @filter_query = filter_query.where("patient_results.core_fields like ?", "%status: #{params['status']}%") if params["status"].present?
  # end

  def filter_by_date
    since_day = start_date + ' 00:00'
    until_day = end_date + ' 23:59'
    @filter_query = filter_query.where({ 'patient_results.created_at' => since_day..until_day })
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
end
