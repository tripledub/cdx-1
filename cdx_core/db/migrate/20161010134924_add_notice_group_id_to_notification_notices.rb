class AddNoticeGroupIdToNotificationNotices < ActiveRecord::Migration
  def change
    add_column :notification_notices, :notice_group_id, :integer
  end
end
