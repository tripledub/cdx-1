class AddHistoryOptionsToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :initial_history, :string
    add_column :episodes, :previous_history, :string
  end
end
