class CreateNotificationRecipients < ActiveRecord::Migration
  def change
    create_table :notification_recipients do |t|
      t.integer  :notification_id

      t.string   :first_name
      t.string   :last_name
      t.string   :email
      t.string   :telephone

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
