class CreateNotificationStatuses < ActiveRecord::Migration
  def change
    create_table :notification_statuses do |t|
      t.integer  :notification_id
      t.string   :test_status

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
