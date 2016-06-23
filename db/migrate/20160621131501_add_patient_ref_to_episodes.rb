class AddPatientRefToEpisodes < ActiveRecord::Migration
  def change
    add_reference :episodes, :patient, index: true, foreign_key: true
  end
end
