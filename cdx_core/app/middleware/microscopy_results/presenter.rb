module MicroscopyResults
  # Presenter methods for microscopy results
  class Presenter
    class << self
      def index_table(microscopy_results)
        microscopy_results.map do |microscopy_result|
          {
            id:                microscopy_result.uuid,
            sampleCollectedAt: Extras::Dates::Format.datetime_with_time_zone(microscopy_result.sample_collected_at, :full_time),
            examinedBy:        microscopy_result.examined_by,
            resultOn:          Extras::Dates::Format.datetime_with_time_zone(microscopy_result.result_at, :full_time),
            specimenType:      microscopy_result.specimen_type.blank? ? "": I18n.t("test_results.index.specimen_type.#{microscopy_result.specimen_type}"),
            serialNumber:      microscopy_result.serial_number,
            testResult:        Extras::Select.find(MicroscopyResult.test_result_options, microscopy_result.test_result),
            appearance:        Extras::Select.find(MicroscopyResult.visual_appearance_options, microscopy_result.appearance),
            viewLink:          Rails.application.routes.url_helpers.encounter_microscopy_result_path(microscopy_result.encounter, microscopy_result)
          }
        end
      end

      def csv_query(microscopy_results)
        microscopy_results.map do |microscopy_result|
          {
            id:                microscopy_result.uuid,
            sampleCollectedAt: Extras::Dates::Format.datetime_with_time_zone(microscopy_result.sample_collected_at, :full_time),
            examinedBy:        microscopy_result.examined_by,
            resultOn:          Extras::Dates::Format.datetime_with_time_zone(microscopy_result.result_at, :full_time),
            specimenType:      microscopy_result.specimen_type.blank? ? '' : I18n.t("test_results.index.specimen_type.#{microscopy_result.specimen_type}"),
            serialNumber:      microscopy_result.serial_number,
            testResult:        Extras::Select.find(MicroscopyResult.test_result_options, microscopy_result.test_result),
            appearance:        Extras::Select.find(MicroscopyResult.visual_appearance_options, microscopy_result.appearance),
            resultStatus:      Extras::Select.find(MicroscopyResult.status_options, microscopy_result.result_status),
            feedbackMessage:   FeedbackMessages::Finder.find_text_from_patient_result(microscopy_result),
            comment:           microscopy_result.comment
          }
        end
      end
    end
  end
end
