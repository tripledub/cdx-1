class NewPatientPage < CdxPageBase
  set_url "/patients/new{?query*}"

  element :name, :field, "NAME"
  element :patient_id, :field, "Patient id"
  element :dob, :field, "Birthday"
end
