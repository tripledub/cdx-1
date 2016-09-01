class AddPresumptiveTbToEncounter < ActiveRecord::Migration
  def change
    add_column :encounters, :presumptive_rr, :boolean
  end
end
