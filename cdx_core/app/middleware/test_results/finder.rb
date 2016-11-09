module TestResults
  # Test results finder
  class Finder
    include PatientResults::FinderFilters

    protected

    def init_query
      @filter_query =
        TestResult.joins('LEFT OUTER JOIN institutions ON institutions.id = patient_results.institution_id')
                  .joins('LEFT OUTER JOIN sites ON sites.id = patient_results.site_id')
                  .joins('LEFT OUTER JOIN devices ON devices.id = patient_results.device_id')
                  .joins('LEFT OUTER JOIN sample_identifiers ON sample_identifiers.id = patient_results.sample_identifier_id')
    end

    def filter_by_failed
      @filter_query = filter_query.where('patient_results.result_status IN (?)', %w(invalid error no_result)) if params['failed']
    end
  end
end
