class CreateNotificationNoticeGroups < ActiveRecord::Migration
  def change
    create_table :notification_notice_groups do |t|
      t.text     :email_data
      t.text     :telephone_data

      t.string   :status, default: 'pending'

      t.string   :frequency
      t.string   :frequency_value
      t.datetime :triggered_at

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
