class AddMessagesToNotificationNoticeGroups < ActiveRecord::Migration
  def change
    add_column :notification_notice_groups, :sms_messages, :text
    add_column :notification_notice_groups, :email_messages, :text
  end
end
