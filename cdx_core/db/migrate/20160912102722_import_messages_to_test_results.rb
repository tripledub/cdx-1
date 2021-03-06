class ImportMessagesToTestResults < ActiveRecord::Migration
  def change
    create_table :assay_results do |t|
      t.string  :assayable_type
      t.integer :assayable_id
      t.string  :name
      t.string  :condition
      t.string  :result
      t.string  :quantitative_result
      t.text    :assay_data
      t.string  :uuid
      t.timestamps
    end

    add_column :patient_results, :result_name, :string
    add_column :patient_results, :result_status, :string
    add_column :patient_results, :result_type, :string

    add_index :assay_results, [:assayable_type, :assayable_id]
    add_index :assay_results, :condition
    add_index :assay_results, :result
    add_index :assay_results, :quantitative_result
    add_index :assay_results, :uuid
    add_index :assay_results, :created_at
  end
end
