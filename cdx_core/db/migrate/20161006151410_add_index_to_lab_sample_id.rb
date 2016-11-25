# Add index to lab_sample_id
class AddIndexToLabSampleId < ActiveRecord::Migration
  def change
    add_index :sample_identifiers, :lab_sample_id
  end
end
