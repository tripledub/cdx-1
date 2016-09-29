class AddExternalPatientSystemToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :external_patient_system, :string
  end
end