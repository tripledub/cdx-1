module EncountersHelper
  def encounter_context(navigation_context)
    context = navigation_context.to_hash
    context[:site] ||= site(navigation_context)
    context
  end

  def site(navigation_context)
    sites = navigation_context.institution.sites
    site = sites.sort_by(&:name).first
    return { name: site.name, uuid: site.uuid } if site
  end
end
