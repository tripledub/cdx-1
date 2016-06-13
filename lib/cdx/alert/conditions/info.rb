class Cdx::Alert::Conditions::Info
  def initialize(alert_info, params_conditions_info)
    @alert_info      = alert_info
    @conditions_info = params_conditions_info
  end

  def create
    return unless @conditions_info

    conditions = @conditions_info.split(',')
    query_conditions=[]
    conditions.each do |conditionid|
      condition = Condition.find_by_id(conditionid)
      @alert_info.conditions << condition
      query_conditions << condition.name
    end

    query_conditions
  end
end
