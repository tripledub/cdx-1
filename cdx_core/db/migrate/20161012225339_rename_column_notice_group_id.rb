class RenameColumnNoticeGroupId < ActiveRecord::Migration
  def change
    rename_column :notification_notices, :notice_group_id, :notification_notice_group_id
  end
end
