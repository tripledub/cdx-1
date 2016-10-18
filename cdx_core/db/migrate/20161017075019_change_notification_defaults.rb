class ChangeNotificationDefaults < ActiveRecord::Migration
  def change
    change_column_default :notifications, :frequency, 'aggregate'
    change_column_default :notifications, :frequency_value, 'daily'
  end
end
