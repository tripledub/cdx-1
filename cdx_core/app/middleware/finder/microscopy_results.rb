class Finder::MicroscopyResults < Finder::ManualResults
  def results_class
    ::MicroscopyResult
  end

  protected

  def apply_filters
    super
    filter_by_appearance
  end

  def filter_by_appearance
    @filter_query = filter_query.where('patient_results.appearance = ?', params['appearance']) if params['appearance'].present?
  end
end
