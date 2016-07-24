class ModifyPatientResultsFields < ActiveRecord::Migration
  def change
    remove_column    :patient_results, :results_negative,     :boolean, default: false
    remove_column    :patient_results, :results_1to9,         :boolean, default: false
    remove_column    :patient_results, :results_1plus,        :boolean, default: false
    remove_column    :patient_results, :results_2plus,        :boolean, default: false
    remove_column    :patient_results, :results_3plus,        :boolean, default: false
    remove_column    :patient_results, :results_ntm,          :boolean, default: false
    remove_column    :patient_results, :results_contaminated, :boolean, default: false

    add_column :patient_results, :test_result, :string

    add_index :patient_results, :test_result
  end
end
