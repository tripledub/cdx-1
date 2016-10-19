module MicroscopyResults
  # Presenter methods for microscopy results
  class Presenter
    class << self
      def index_table(microscopy_results)
        microscopy_results.map do |microscopy_result|
          {
            id:                microscopy_result.uuid,
            sampleCollectedOn: Extras::Dates::Format.datetime_with_time_zone(microscopy_result.sample_collected_at),
            examinedBy:        microscopy_result.examined_by,
            resultOn:          Extras::Dates::Format.datetime_with_time_zone(microscopy_result.result_at),
            specimenType:      microscopy_result.specimen_type,
            serialNumber:      microscopy_result.serial_number,
            testResult:        Extras::Select.find(MicroscopyResult.test_result_options, microscopy_result.test_result),
            appearance:        Extras::Select.find(MicroscopyResult.visual_appearance_options, microscopy_result.appearance),
            viewLink:          Rails.application.routes.url_helpers.encounter_microscopy_result_path(microscopy_result.encounter, microscopy_result)
          }
        end
      end
    end
  end
end
