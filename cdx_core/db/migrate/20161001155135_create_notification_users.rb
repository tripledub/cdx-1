class CreateNotificationUsers < ActiveRecord::Migration
  def change
    create_table :notification_users do |t|
      t.integer  :notification_id
      t.integer  :user_id

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
