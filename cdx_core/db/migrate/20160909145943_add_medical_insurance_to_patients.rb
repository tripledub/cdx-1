class AddMedicalInsuranceToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :medical_insurance_num, :string
  end
end
