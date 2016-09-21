class AddDefaultValueToClosedEpisodes < ActiveRecord::Migration
  def up
    change_column :episodes, :closed, :boolean, :default => false
    add_column    :episodes, :created_at, :datetime
    add_column    :episodes, :updated_at, :datetime

    Episode.where('closed IS NULL').update_all(closed: false)
    Episode.update_all(created_at: Time.now)
    Episode.update_all(updated_at: Time.now)
  end

  def down
    change_column :episodes, :closed, :boolean
    remove_column :episodes, :created_at, :datetime
    remove_column :episodes, :updated_at, :datetime
  end
end
