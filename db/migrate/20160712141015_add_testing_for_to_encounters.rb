class AddTestingForToEncounters < ActiveRecord::Migration
  def change
    add_column :encounters, :testing_for, :string, default: ''
  end
end
