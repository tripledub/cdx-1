class CreateNotificationRoles < ActiveRecord::Migration
  def change
    create_table :notification_roles do |t|
      t.integer  :notification_id
      t.integer  :role_id

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
