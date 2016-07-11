class EncounterAuditLog < AuditLog
  validates_presence_of  :encounter_id
end
