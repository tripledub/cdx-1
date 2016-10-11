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

  def encounter_routes(encounter)
    {
      submitSamplesUrl: update_samples_encounter_patient_results_path(encounter),
      updateResultUrl: encounter_patient_results_path(encounter),
      updateTestOrderUrl: patient_patient_test_order_path(encounter.patient, encounter)
    }
  end
end
