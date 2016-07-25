class Presenters::MicroscopyResults
  class << self
    def index_table(microscopy_results)
      microscopy_results.map do |microscopy_result|
        {
          id:                microscopy_result.uuid,
          sampleCollectedOn: Extras::Dates::Format.datetime_with_time_zone(microscopy_result.sample_collected_on),
          examinedBy:        microscopy_result.examined_by,
          resultOn:          Extras::Dates::Format.datetime_with_time_zone(microscopy_result.result_on),
          specimenType:      microscopy_result.specimen_type,
          serialNumber:      microscopy_result.serial_number,
          testResult:        Extras::Select.find(MicroscopyResult.test_result_options, microscopy_result.test_result),
          appearance:        Extras::Select.find(MicroscopyResult.visual_appearance_options, microscopy_result.appearance),
          viewLink:          Rails.application.routes.url_helpers.requested_test_microscopy_result_path(requested_test_id: microscopy_result.requested_test.id)
        }
      end
    end
  end
end
