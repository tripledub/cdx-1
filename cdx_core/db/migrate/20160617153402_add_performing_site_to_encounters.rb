class AddPerformingSiteToEncounters < ActiveRecord::Migration
  def change
    add_reference :encounters, :performing_site, references: :sites, index: true
  end
end
