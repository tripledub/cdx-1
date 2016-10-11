# Add device to audit logs
class AddDeviceToAuditLog < ActiveRecord::Migration
  def change
    add_column :audit_logs, :device_id, :integer
    add_index  :audit_logs, :device_id
  end
end
