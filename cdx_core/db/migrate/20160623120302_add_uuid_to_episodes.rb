class AddUuidToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :uuid, :string
  end
end
