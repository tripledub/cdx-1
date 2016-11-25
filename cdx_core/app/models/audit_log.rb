# AuditLog
# Audit and log activities related to patients.
class AuditLog < ActiveRecord::Base
  include AutoUUID

  belongs_to :patient
  belongs_to :user
  belongs_to :encounter
  belongs_to :patient_result
  belongs_to :device

  has_many   :audit_updates, dependent: :destroy

  validates_presence_of :title, :patient_id
end
