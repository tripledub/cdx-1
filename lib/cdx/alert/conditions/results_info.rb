class Cdx::Alert::Conditions::ResultsInfo
  attr_reader :condition_result_ok, :error_text

  def initialize(alert_info, params_condition_results_info)
    @alert_info             = alert_info
    @condition_results_info = params_condition_results_info
    @condition_result_ok     = true
    @error_text              = ''
  end

  def create
    condition_results       = @condition_results_info.split(',')
    query_condition_results = []

    condition_results.each do |condition_result_name|
      alert_condition_result = @alert_info.alert_condition_results.new do |result|
        result.result = condition_result_name
      end
      if alert_condition_result.save == false
        @condition_result_ok = false
        @error_text          = alert_condition_result.errors.messages
      end
      query_condition_results << condition_result_name
    end

    query_condition_results
  end
end
