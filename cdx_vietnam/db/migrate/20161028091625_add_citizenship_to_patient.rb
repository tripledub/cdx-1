class AddCitizenshipToPatient < ActiveRecord::Migration
  def change
    add_column  :patients, :nationality, :string
  end
end
