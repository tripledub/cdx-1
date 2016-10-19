# Update samples_received and result_date as datetimes.
class ChangeDateToDateTimeInPatientResults < ActiveRecord::Migration
  def change
    change_column :patient_results, :sample_collected_on, :datetime
    change_column :patient_results, :result_on, :datetime

    rename_column :patient_results, :sample_collected_on, :sample_collected_at
    rename_column :patient_results, :result_on, :result_at
  end
end
