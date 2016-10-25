class CreateNotificationNotices < ActiveRecord::Migration
  def change
    create_table :notification_notices do |t|
      t.integer :notification_id

      t.string  :alertable_type
      t.integer :alertable_id

      t.text :data

      t.string  :status, default: 'pending'

      t.timestamps
    end
  end
end
