class AddSyncIdToPatient < ActiveRecord::Migration
  def change
    add_column  :patients, :etb_patient_id, :string
    add_column  :patients, :vtm_patient_id, :string
  end
end
