class Presenters::PatientTestResults
  class << self
    def patient_view(patient_results)
      patient_results.map do |result|
        {
          id:              result.uuid,
          name:            result.core_fields[TestResult::NAME_FIELD],
          date:            Extras::Dates::Format.datetime_with_time_zone(result.core_fields[TestResult::START_TIME_FIELD]),
          status:          result.core_fields[TestResult::STATUS_FIELD],
          viewLink:        Rails.application.routes.url_helpers.test_result_path(result)
        }
      end
    end
  end
end
