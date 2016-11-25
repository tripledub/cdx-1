# Saves all different changes occurred to all activities related to patients.
class AuditUpdate < ActiveRecord::Base
  include AutoUUID

  belongs_to :audit_log

  validates_presence_of :field_name
end
