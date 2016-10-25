class CreateNotificationSites < ActiveRecord::Migration
  def change
    create_table :notification_sites do |t|
      t.integer  :notification_id
      t.integer  :site_id

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
