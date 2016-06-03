class AddAddressInfoToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :state, :string
    add_column :patients, :city, :string
    add_column :patients, :zip_code, :string
  end
end
