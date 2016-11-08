class AddIsSyncVtmToPatientResult < ActiveRecord::Migration
  def change
    add_column    :patient_results, :is_sync_vtm, :boolean, :default => false
  end
end
