class AddTraceToResults < ActiveRecord::Migration
  def change
    add_column :patient_results, :trace, :string
  end
end
