# Vietnam has this custom identifiers imprted from gene xpert.
class AddLabFieldsToSampleIdentifiers < ActiveRecord::Migration
  def change
    add_column    :sample_identifiers, :lab_id_sample, :string
    add_column    :sample_identifiers, :lab_id_patient, :string
  end
end
