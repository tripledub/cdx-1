# Add new fields to store ids from gene xpert
class AddLabFieldsToSampleIdentifiers < ActiveRecord::Migration
  def change
    add_column    :sample_identifiers, :cpd_id_sample, :string
    add_column    :sample_identifiers, :lab_id_patient, :string
    rename_column :sample_identifiers, :lab_sample_id, :lab_id_sample
  end
end
