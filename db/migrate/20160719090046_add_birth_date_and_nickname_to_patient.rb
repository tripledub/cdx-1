class AddBirthDateAndNicknameToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :nickname, :string
    add_column :patients, :birth_date_on_on, :date
    add_index  :patients, :birth_date_on_on
  end
end
