class Cdx::Alert::Conditions::Sample
  def initialize(alert_info, params_sample_id)
    @alert_info = alert_info
    @sample_id  = params_sample_id
  end

  def create
    return unless @sample_id && @sample_id.length > 0

    @alert_info.query.merge!({ "sample.id" => @sample_id })
  end
end
