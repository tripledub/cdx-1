require 'machinist/active_record'
require 'faker'

Patient.blueprint do
  name Faker::Name.name
  institution
  is_phantom { false }
  social_security_code { Faker::Number.hexadecimal(11) }
  plain_sensitive_data {
    {}.tap do |h|
      h["id"]   = object.entity_id || "patient-#{Sham.sn}"
      h["name"] = object.name if object.name
    end
  }
end

Address.blueprint do
  address  { Faker::Address.street_address }
  city     { Faker::Address.city }
  state    { Address.regions.map(&:first).sample }
  country  { Faker::Address.country }
  zip_code { nil }
end

IntegrationLog.blueprint do
  patient_name Faker::Name.name
  order_id "CDP00001"
end

PatientResult.blueprint do

end
