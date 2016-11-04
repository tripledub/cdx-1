module PatientResults
  # Finder for patient results
  class Finder
    include PatientResults::FinderFilters

    attr_reader :params, :filter_query

    def initialize(navigation_context, params)
      @navigation_context = navigation_context
      @params             = params
      apply_filters
    end
  end
end
