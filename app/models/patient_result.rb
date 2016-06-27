class PatientResult < ActiveRecord::Base
  belongs_to :patient
  belongs_to :encounter

  validate :validate_encounter
  validate :validate_patient
end
