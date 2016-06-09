class Cdx::Alert::Conditions::Institutions
  def initialize(alert_info)
    @alert_info   = alert_info
  end

  def create
    institution = Institution.find(@alert_info.institution_id)
    @alert_info.query.merge!({ "institution.uuid" => institution.uuid })
  end
end
