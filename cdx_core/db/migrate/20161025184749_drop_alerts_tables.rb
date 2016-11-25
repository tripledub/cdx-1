class DropAlertsTables < ActiveRecord::Migration
  def change
    drop_table :alert_condition_results
    drop_table :alert_histories
    drop_table :alert_recipients
    drop_table :alerts
    drop_table :recipient_notification_histories
  end
end
