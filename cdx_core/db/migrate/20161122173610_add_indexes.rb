# Add indexes to tables to increase performance
class AddIndexes < ActiveRecord::Migration
  def change
    add_index :audit_updates, :field_name
    add_index :notification_conditions, [:condition_type, :field, :value], name: 'notification_conditions_type_field_value'
    add_index :notification_conditions, :notification_id
    add_index :notification_conditions, :deleted_at
    add_index :notifications, :institution_id
    add_index :notifications, :encounter_id
    add_index :notifications, :user_id
    add_index :notifications, :patient_id
    add_index :notifications, :enabled
    add_index :notifications, :frequency
    add_index :notification_roles, :notification_id
    add_index :notification_roles, :role_id
    add_index :notification_recipients, :notification_id
    add_index :notification_notices, :notification_id
    add_index :notification_notices, :notification_notice_group_id
    add_index :notification_notices, [:alertable_type, :alertable_id]
    add_index :notification_notices, :created_at
    add_index :notification_notices, :status
    add_index :notification_notice_recipients, :notification_id
    add_index :notification_notice_recipients, :notification_notice_id
    add_index :notification_notice_groups, :institution_id
    add_index :notification_notice_groups, :deleted_at
    add_index :notification_devices, :notification_id
    add_index :notification_devices, :device_id
    add_index :notification_devices, :deleted_at
    add_index :notification_sites, :notification_id
    add_index :notification_sites, :site_id
    add_index :notification_sites, :deleted_at
    add_index :notification_statuses, :notification_id
    add_index :notification_statuses, :deleted_at
    add_index :notification_statuses, :test_status
    add_index :notification_users, :notification_id
    add_index :notification_users, :user_id
    add_index :notification_users, :deleted_at
    add_index :computed_policies, :user_id
    add_index :computed_policies, [:resource_type, :resource_id]
    add_index :computed_policies, :condition_institution_id
    add_index :computed_policies, :condition_site_id
    add_index :computed_policies, :condition_device_id
    add_index :computed_policies, :include_subsites
    add_index :computed_policy_exceptions, :computed_policy_id
    add_index :computed_policy_exceptions, [:resource_type, :resource_id], name: 'computed_policy_exceptions_type_id'
    add_index :computed_policy_exceptions, :condition_institution_id
    add_index :computed_policy_exceptions, :condition_site_id
    add_index :computed_policy_exceptions, :condition_device_id
    add_index :conditions, :name
    add_index :conditions_manifests, [:manifest_id, :condition_id]
    add_index :device_commands, :device_id
    add_index :device_logs, :device_id
    add_index :device_models, :institution_id
    add_index :devices, :institution_id
    add_index :devices, :device_model_id
    add_index :devices, :site_id
    add_index :devices, :uuid
    add_index :encounters, :uuid
    add_index :encounters, :institution_id
    add_index :encounters, :patient_id
    add_index :encounters, :entity_id
    add_index :episodes, :closed
    add_index :episodes, :closed_at
    add_index :episodes, :uuid
    add_index :institutions, :uuid
    add_index :integration_logs, :order_id
    add_index :manifests, :device_model_id
    add_index :patient_results, :type
    add_index :patient_results, :result_at
    add_index :patient_results, :result_status
    add_index :patients, :is_phantom
    add_index :patients, :name
    add_index :patients, :external_id
    add_index :patients, [:external_patient_system, :external_system_id]
    add_index :policies, :user_id
    add_index :policies, :granter_id
    add_index :roles, :institution_id
    add_index :roles, :site_id
    add_index :roles, :policy_id
    add_index :roles_users, [:role_id, :user_id]
    add_index :sample_identifiers, :site_id
    add_index :sample_identifiers, :lab_id_sample
    add_index :sample_identifiers, :lab_id_patient
    add_index :sites, :institution_id
    add_index :sites, :uuid
    add_index :sites, :parent_id
    add_index :subscribers, :user_id
    add_index :test_result_parsed_data, :test_result_id
  end
end
