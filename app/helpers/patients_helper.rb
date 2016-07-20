module PatientsHelper
  def patient_address_component(patient)
    react_component 'Address',
      latName: 'patient[lat]', lngName: 'patient[lng]', addressName: 'patient[address]', locationName: 'patient[location_geoid]',
      defaultLocation: patient.location_geoid,
      defaultAddress: patient.address,
      defaultLatLng: { lat: patient.lat, lng: patient.lng }
  end

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
