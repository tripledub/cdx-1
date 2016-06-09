class Cdx::Alert::Conditions::SitesInfo
  def initialize(alert_info, params_sites_info)
    @alert_info = alert_info
    @sites_info = params_sites_info
  end

  def create
    return unless @sites_info.present?

    sites       = @sites_info.split(',')
    query_sites = []
    sites.each do |siteid|
      site = Site.find_by_id(siteid)
      @alert_info.sites << site
      query_sites       << site.uuid
    end

    @alert_info.query.merge!({ "site.uuid" => query_sites })
  end
end
