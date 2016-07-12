class AddEncounterStiToAuditLogs < ActiveRecord::Migration
  def change
    add_column    :audit_logs, :type, :string, index: true
    add_reference :audit_logs, :encounter, foreign_key: true
    add_reference :audit_logs, :requested_test, foreign_key: true
    add_reference :audit_logs, :patient_result, foreign_key: true
  end
end
