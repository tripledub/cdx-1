class AddMethodUsedToPatientResults < ActiveRecord::Migration
  def change
    add_column :patient_results, :method_used, :string
    add_index :patient_results, :method_used
  end
end
