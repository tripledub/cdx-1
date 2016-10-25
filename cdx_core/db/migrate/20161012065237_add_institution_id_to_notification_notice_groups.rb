class AddInstitutionIdToNotificationNoticeGroups < ActiveRecord::Migration
  def change
    add_column :notification_notice_groups, :institution_id, :integer
  end
end
