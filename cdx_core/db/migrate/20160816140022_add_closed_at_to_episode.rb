class AddClosedAtToEpisode < ActiveRecord::Migration
  def change
    add_column :episodes, :closed_at, :datetime
  end
end
