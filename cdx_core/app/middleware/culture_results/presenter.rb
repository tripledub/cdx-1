module CultureResults
  # Presenter methods for culture results
  class Presenter
    class << self
      def index_table(culture_results)
        culture_results.map do |culture_result|
          {
            id:                culture_result.uuid,
            sampleCollectedAt: Extras::Dates::Format.datetime_with_time_zone(culture_result.sample_collected_at, :full_time),
            examinedBy:        culture_result.examined_by,
            resultOn:          Extras::Dates::Format.datetime_with_time_zone(culture_result.result_at, :full_time),
            mediaUsed:         Extras::Select.find(CultureResult.media_options, culture_result.media_used),
            serialNumber:      culture_result.serial_number,
            testResult:        Extras::Select.find(CultureResult.test_result_options, culture_result.test_result),
            viewLink:          Rails.application.routes.url_helpers.encounter_culture_result_path(culture_result.encounter, culture_result)
          }
        end
      end
    end
  end
end
