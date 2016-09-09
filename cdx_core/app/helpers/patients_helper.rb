module PatientsHelper
  def patient_diagnostic(encounter)
    encounter.diagnostic.blank? ? "Pending" : encounter.human_diagnose
  end

  def patient_observations(encounter)
    encounter.observations.blank? ? "No comments" : encounter.observations
  end

  def patient_display_name(patient_name)
    patient_name.present? ? patient_name : '(Unknown name)'
  end

  def set_default_tab
    default_cookie = cookies['defaultTab'].to_i
    default_cookie = 1 if (default_cookie < 1) || (default_cookie > 4)
    default_cookie
  end
end
