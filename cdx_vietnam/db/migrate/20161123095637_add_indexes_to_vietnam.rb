# Add missing indexes to vietnam specific fields
class AddIndexesToVietnam < ActiveRecord::Migration
  def change
    add_index :patients, :etb_patient_id
    add_index :patients, :vtm_patient_id
    add_index :sample_identifiers, :lab_id_sample
    add_index :sample_identifiers, :lab_id_patient
  end
end
