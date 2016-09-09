class PatientResult < ActiveRecord::Base
  include AutoUUID
  include Auditable

  belongs_to :requested_test

  after_save :update_requested_test

  before_save :convert_string_to_dates

  class << self
    def find_associated_tests_to_results(encounter)
      PatientResult.joins(:requested_test).where('requested_tests.encounter_id' => encounter.id).pluck(:id, :requested_test_id).map do |result|
       { id: result[0], requested_test_id: result[1] }
      end
    end

    def find_all_for_patient(patient_id)
      PatientResult.joins('LEFT OUTER JOIN `requested_tests` ON `requested_tests`.`id` = `patient_results`.`requested_test_id` LEFT OUTER JOIN `encounters` ON `encounters`.`id` = `requested_tests`.`encounter_id`')
        .where('patient_results.patient_id = ? OR encounters.patient_id = ?', patient_id, patient_id)
    end
  end

  protected

  def convert_string_to_dates
    sample_collected_on = Extras::Dates::Format.string_to_pattern(sample_collected_on) if sample_collected_on.present? && sample_collected_on.is_a?(String)
    result_on           = Extras::Dates::Format.string_to_pattern(result_on) if result_on.present? && result_on.is_a?(String)
  end

  def update_requested_test
    return unless requested_test.present?

    TestStatus.change_status(self)
  end
end
