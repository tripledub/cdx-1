# Remove test_batch model
class RemoveTestBatches < ActiveRecord::Migration
  def change
    drop_table :test_batches

    remove_column :patient_results, :test_batch_id
    remove_column :patient_results, :requested_test_id
    add_column :encounters, :payment_done, :boolean, default: false
  end
end
