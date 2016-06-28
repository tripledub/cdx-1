class PatientResult < ActiveRecord::Base
  include AutoUUID

  belongs_to :requested_test, :polymorphic => true
end
