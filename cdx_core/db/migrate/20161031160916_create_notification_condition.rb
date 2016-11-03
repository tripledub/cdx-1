class CreateNotificationCondition < ActiveRecord::Migration
  def change
    create_table :notification_conditions do |t|
      t.integer :notification_id

      t.string  :condition_type
      t.string  :field
      t.string  :value

      t.datetime :deleted_at

      t.timestamps null: true
    end
  end
end
