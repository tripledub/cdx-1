class CreateNotificationDevices < ActiveRecord::Migration
  def change
    create_table :notification_devices do |t|
      t.integer  :notification_id
      t.integer  :device_id

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
