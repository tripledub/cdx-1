class AddIsSyncToPatientResult < ActiveRecord::Migration
  def change
    add_column    :patient_results, :is_sync, :boolean, :default => false
  end
end
