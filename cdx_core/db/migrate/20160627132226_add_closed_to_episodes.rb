class AddClosedToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :closed, :boolean
  end
end
