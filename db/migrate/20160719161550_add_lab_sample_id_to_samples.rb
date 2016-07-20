class AddLabSampleIdToSamples < ActiveRecord::Migration
  def change
    add_column :sample_identifiers, :lab_sample_id, :string
  end
end
