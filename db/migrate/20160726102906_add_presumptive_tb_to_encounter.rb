class AddPresumptiveTbToEncounter < ActiveRecord::Migration
  def change
    add_column :encounters, :presumptive_tb, :boolean
  end
end
