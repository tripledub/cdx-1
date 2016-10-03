class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :institution_id
      t.integer :encounter_id
      t.integer :user_id
      t.integer :patient_id

      t.string  :name
      t.string  :description
      t.boolean :enabled, default: false

      # Test Result alerts
      t.string  :test_identifier
      t.string  :sample_identifier
      t.string  :patient_identifier

      t.string  :detection
      t.string  :detection_condition

      # Device alerts
      t.string  :device_error_code

      # Anomaly alerts
      t.string  :anomaly_type

      # Utilisation efficiency alerts
      t.integer  :utilisation_efficiency_threshold
      t.datetime :utilisation_efficiency_last_checked_at

      # Options
      t.string  :frequency,   default: 'instant'
      t.string  :frequency_value

      t.boolean :email,       default: false
      t.text    :email_message
      t.integer :email_limit, default: 100

      t.boolean :sms,         default: false
      t.text    :sms_message
      t.integer :sms_limit,   default: 100

      t.integer :site_id
      t.string  :site_prefix

      t.datetime :last_notification_at
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
