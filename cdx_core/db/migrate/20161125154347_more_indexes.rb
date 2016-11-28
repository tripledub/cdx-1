# Improve performance of test orders
class MoreIndexes < ActiveRecord::Migration
  def change
    add_index :patient_results, [:deleted_at, :encounter_id]
    add_index :samples, [:deleted_at, :encounter_id]
  end
end
