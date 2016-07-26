class Finder::DstLpaResults < Finder::ManualResults
  def results_class
    ::DstLpaResult
  end

  protected

  def apply_filters
    super
    filter_by_results_h
    filter_by_results_r
    filter_by_results_e
    filter_by_results_s
    filter_by_results_amk
    filter_by_results_km
    filter_by_results_cm
    filter_by_results_fq
  end

  def filter_by_results_h
    @filter_query = filter_query.where('patient_results.results_h = ?', params['results_h']) if params['results_h'].present?
  end

  def filter_by_results_r
    @filter_query = filter_query.where('patient_results.results_r = ?', params['results_r']) if params['results_r'].present?
  end

  def filter_by_results_e
    @filter_query = filter_query.where('patient_results.results_e = ?', params['results_e']) if params['results_e'].present?
  end

  def filter_by_results_s
    @filter_query = filter_query.where('patient_results.results_s = ?', params['results_s']) if params['results_s'].present?
  end

  def filter_by_results_amk
    @filter_query = filter_query.where('patient_results.results_amk = ?', params['results_amk']) if params['results_amk'].present?
  end

  def filter_by_results_km
    @filter_query = filter_query.where('patient_results.results_km = ?', params['results_km']) if params['results_km'].present?
  end

  def filter_by_results_cm
    @filter_query = filter_query.where('patient_results.results_cm = ?', params['results_cm']) if params['results_cm'].present?
  end

  def filter_by_results_fq
    @filter_query = filter_query.where('patient_results.results_fq = ?', params['results_fq']) if params['results_fq'].present?
  end
end
