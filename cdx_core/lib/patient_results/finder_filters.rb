module PatientResults
  # Filter options for test and patient results
  module FinderFilters
    attr_reader :params, :filter_query, :number_of_days

    def initialize(navigation_context, params)
      @navigation_context = navigation_context
      @params             = params
      apply_filters
    end

    protected

    def apply_filters
      init_query
      filter_by_navigation_context
      filter_by_device
      filter_by_date
      filter_by_type
      filter_by_status
      filter_by_sample_identifier
      filter_by_assay_result
      filter_by_failed
    end

    def init_query
      @filter_query =
        PatientResult.joins('LEFT OUTER JOIN encounters ON encounters.id = patient_results.encounter_id')
                     .joins('LEFT OUTER JOIN institutions ON institutions.id = encounters.institution_id')
                     .joins('LEFT OUTER JOIN sites ON sites.id = encounters.site_id')
                     .joins('LEFT OUTER JOIN devices ON devices.id = patient_results.device_id')
                     .joins('LEFT OUTER JOIN sample_identifiers ON sample_identifiers.id = patient_results.sample_identifier_id')
    end

    def filter_by_navigation_context
      @filter_query = filter_query.where('institutions.id = ?', @navigation_context.institution.id) if @navigation_context.institution

      if @navigation_context.exclude_subsites && @navigation_context.site
        @filter_query = filter_query.where('sites.id = ?', @navigation_context.site.id)
      elsif !@navigation_context.exclude_subsites && @navigation_context.site
        subsites = []
        @navigation_context.site.walk_tree { |site, _level| subsites << site.id }
        @filter_query = filter_query.where('sites.id = ? OR sites.id IN (?)', @navigation_context.site.id, subsites)
      end
    end

    def filter_by_device
      @filter_query = filter_query.where('devices.uuid = ?', params['device_uuid']) if params['device_uuid'].present?
      @filter_query = filter_query.where('devices.id = ?', params['device']) if params['device'].present?
    end

    def filter_by_sample_identifier
      @filter_query = filter_query.where('sample_identifiers.entity_id = ?', params['sample_entity']) if params['sample_entity'].present?
      @filter_query = filter_query.where('sample_identifiers.id = ?', params['sample_id']) if params['sample_id'].present?
    end

    def filter_by_assay_result
      @filter_query = filter_query.where(
        'patient_results.id IN (SELECT assayable_id FROM assay_results where assayable_type="PatientResult" AND result=?)',
        params['result_type']
      ) if params['result_type'].present?
    end

    def filter_by_status
      return unless params['status'].present?

      if params['status'] == 'error'
        @filter_query = filter_query.where('patient_results.result_status = "error" OR patient_results.tuberculosis = "error"')
      else
        @filter_query = filter_query.where('patient_results.result_status = ?', params['status'])
      end
    end

    def filter_by_type
      @filter_query = filter_query.where('patient_results.type != "TestResult"') if params['manual']
    end

    def filter_by_date
      since_day = start_date + ' 00:00'
      until_day = end_date + ' 23:59'
      @number_of_days = (Time.parse(until_day) - Time.parse(since_day)).to_i / 86_400
      @filter_query = filter_query.where('patient_results.result_at' => since_day..until_day)
    end

    def start_date
      if start_range
        params['range']['start_time']['gte']
      elsif params['since'].present?
        params['since']
      elsif params['from_date'].present?
        params['from_date']
      else
        7.days.ago.strftime('%Y-%m-%d')
      end
    end

    def end_date
      if end_range
        params['range']['start_time']['lte']
      elsif params['to_date'].present?
        params['to_date']
      else
        Date.today.strftime('%Y-%m-%d')
      end
    end

    def start_range
      params['range'].present? && params['range']['start_time'].present? && params['range']['start_time']['gte'].present?
    end

    def end_range
      params['range'].present? && params['range']['start_time'].present? && params['range']['start_time']['lte'].present?
    end
  end
end
