class AddExternalSystemIdToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :external_system_id, :integer
    add_index :patients, :external_system_id
  end
end
