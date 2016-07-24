module EncountersHelper
  def encounter_context(navigation_context)
    unless navigation_context.site
      institution = navigation_context.institution
      site = institution.sites.first
      navigation_context.site = site
    end
    navigation_context.to_hash
  end
end
