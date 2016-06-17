module PatientsHelper
  def patient_address_component(patient)
    react_component 'Address',
      latName: 'patient[lat]', lngName: 'patient[lng]', addressName: 'patient[address]', locationName: 'patient[location_geoid]',
      defaultLocation: patient.location_geoid,
      defaultAddress: patient.address,
      defaultLatLng: { lat: patient.lat, lng: patient.lng }
  end

  def patient_birth_date(dob)
    return unless dob

    birth_date = Time.parse(dob)
    return unless birth_date

    "#{birth_date.strftime(I18n.t('date.input_format.pattern'))} - #{birth_date_to_words(birth_date)}"
  end

  def birth_date_to_words(birth_date)
    years = Date.today.year - birth_date.year

    if years > 1
      "#{years}y/o."
    else
      months = (Date.today.year * 12 + Date.today.month) - (birth_date.year * 12 + birth_date.month)
      "#{months}m/o."
    end
  end
end
