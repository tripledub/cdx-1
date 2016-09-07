class AddAnatomicalSiteDiagnosisToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :anatomical_site_diagnosis, :string
  end
end
