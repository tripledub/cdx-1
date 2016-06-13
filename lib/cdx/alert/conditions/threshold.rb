class Cdx::Alert::Conditions::Threshold
  def initialize(alert_info, params_threshold)
    @alert_info = alert_info
    @threshold  = params_threshold
  end

  def create
    return unless @threshold[:min] && @threshold[:max]

    @alert_info.query.merge!({ 'test.assays.quantitative_result' => threshold_query })
  end

  protected

  def threshold_query
    @query = {}

    @query.merge!({ 'test.assays.quantitative_result.min' => @threshold[:min].to_i || 0 })
    @query.merge!({ 'test.assays.quantitative_result.max' => @threshold[:max].to_i || 0 })
  end
end
