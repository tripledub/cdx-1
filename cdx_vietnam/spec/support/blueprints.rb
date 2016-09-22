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