class CreateNotificationNoticeRecipients < ActiveRecord::Migration
  def change
    create_table :notification_notice_recipients do |t|
      t.integer :notification_id
      t.integer :notification_notice_id

      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :telephone

      t.string  :status, default: 'pending'

      t.timestamps
    end
  end
end
