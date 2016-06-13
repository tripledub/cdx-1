class AddTimeoutInSecondsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :timeout_in_seconds, :integer, default: 180
  end
end
