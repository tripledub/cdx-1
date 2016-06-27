class AddStatusToEncounters < ActiveRecord::Migration
  def change
    add_column :encounters, :status, :integer, default:0
  end
end
