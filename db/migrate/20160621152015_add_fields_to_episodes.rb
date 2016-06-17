class AddFieldsToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :hiv_status, :string
    add_column :episodes, :drug_resistance, :string
    add_column :episodes, :outcome, :string
  end
end
