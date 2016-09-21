class Presenters::CultureResults
  class << self
    def index_table(culture_results)
      culture_results.map do |culture_result|
        {
          id:                culture_result.uuid,
          sampleCollectedOn: Extras::Dates::Format.datetime_with_time_zone(culture_result.sample_collected_on),
          examinedBy:        culture_result.examined_by,
          resultOn:          Extras::Dates::Format.datetime_with_time_zone(culture_result.result_on),
          mediaUsed:         Extras::Select.find(CultureResult.media_options, culture_result.media_used),
          serialNumber:      culture_result.serial_number,
          testResult:        Extras::Select.find(CultureResult.test_result_options, culture_result.test_result),
          viewLink:          Rails.application.routes.url_helpers.requested_test_culture_result_path(requested_test_id: culture_result.requested_test.id)
        }
      end
    end
  end
end
