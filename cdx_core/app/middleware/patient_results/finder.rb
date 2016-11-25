module PatientResults
  # Finder for patient results
  class Finder
    include PatientResults::FinderFilters

    protected

    def filter_by_failed
      @filter_query = filter_query.where(
        '(patient_results.tuberculosis IN (?) OR patient_results.test_result = ? OR patient_results.results_h IN (?))',
        %w(indeterminate no_result error), 'contaminated', %w(contaminated not_done)
      ) if params['failed']
    end
  end
end
