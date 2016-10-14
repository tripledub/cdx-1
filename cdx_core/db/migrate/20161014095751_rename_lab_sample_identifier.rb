# Rename lab sample id to a better name also don't end in _id fields that are not related to another table.
class RenameLabSampleIdentifier < ActiveRecord::Migration
  def change
    rename_column :sample_identifiers, :lab_sample_id, :cpd_id_sample
  end
end
