class EncounterTestAuditLog < AuditLog
  validates_presence_of :encounter_id
  validates_presence_of :requested_test_id
end
