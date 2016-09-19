class AddTestBatches < ActiveRecord::Migration
  def change
    create_table :test_batches do |t|
      t.references :encounter, null: false
      t.references :institution, null: false
      t.string     :status
      t.string     :uuid
      t.text       :comment

      t.timestamps
    end

    add_column :patient_results, :comment, :text
    add_column :patient_results, :test_batch_id, :integer
    add_column :patient_results, :completed_at, :datetime
    change_column :encounters, :status, :string, default: ''

    add_index :test_batches, :status
    add_index :test_batches, :uuid
    add_index :test_batches, :encounter_id
    add_index :test_batches, :institution_id

    add_index :patient_results, :completed_at
    add_index :patient_results, :test_batch_id

    add_index :encounters, :status
  end
end
