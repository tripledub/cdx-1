class CreateIntegrationLogs < ActiveRecord::Migration
  def change
    create_table :integration_logs do |t|
      t.string :patient_name
      t.string :order_id
      t.text :json
      t.string :fail_step
      t.string :system
      t.string :error_message
      t.integer :try_n_times
      t.string :status

      t.timestamps
    end
  end
end
