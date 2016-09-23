class AddExternalIdToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :external_id, :string
  end
end
