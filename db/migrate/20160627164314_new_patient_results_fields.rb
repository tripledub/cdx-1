class NewPatientResultsFields < ActiveRecord::Migration
  def change
    add_reference :patient_results, :requested_test, index: true
    add_column    :patient_results, :sample_collected_on,  :date
    add_column    :patient_results, :result_on,            :date
    add_column    :patient_results, :specimen_type,        :string
    add_column    :patient_results, :serial_number,        :string
    add_column    :patient_results, :appearance,           :string
    add_column    :patient_results, :results_negative,     :boolean, default: false
    add_column    :patient_results, :results_1to9,         :boolean, default: false
    add_column    :patient_results, :results_1plus,        :boolean, default: false
    add_column    :patient_results, :results_2plus,        :boolean, default: false
    add_column    :patient_results, :results_3plus,        :boolean, default: false
    add_column    :patient_results, :results_ntm,          :boolean, default: false
    add_column    :patient_results, :results_contaminated, :boolean, default: false
    add_column    :patient_results, :results_h,            :boolean, default: false
    add_column    :patient_results, :results_r,            :boolean, default: false
    add_column    :patient_results, :results_e,            :boolean, default: false
    add_column    :patient_results, :results_s,            :boolean, default: false
    add_column    :patient_results, :results_amk,          :boolean, default: false
    add_column    :patient_results, :results_km,           :boolean, default: false
    add_column    :patient_results, :results_cm,           :boolean, default: false
    add_column    :patient_results, :results_fq,           :boolean, default: false
    add_column    :patient_results, :examined_by,          :string
    add_column    :patient_results, :tuberculosis,         :string
    add_column    :patient_results, :rifampicin,           :string
    add_column    :patient_results, :media_used,           :string
    add_column    :patient_results, :results_other1,       :string
    add_column    :patient_results, :results_other2,       :string
    add_column    :patient_results, :results_other3,       :string
    add_column    :patient_results, :results_other4,       :string
  end
end
