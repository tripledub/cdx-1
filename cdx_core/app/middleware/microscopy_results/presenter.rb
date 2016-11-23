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
            specimenType:      microscopy_result.specimen_type.blank? ? '' : I18n.t("test_results.index.specimen_type.#{microscopy_result.specimen_type}"),
            serialNumber:      microscopy_result.serial_number,
            testResult:        Extras::Select.find(MicroscopyResult.test_result_options, microscopy_result.test_result),
            appearance:        Extras::Select.find(MicroscopyResult.visual_appearance_options, microscopy_result.appearance),
            viewLink:          Rails.application.routes.url_helpers.encounter_microscopy_result_path(microscopy_result.encounter, microscopy_result)
          }
        end
      end

      def csv_query(microscopy_results)
        CSV.generate do |csv|
          csv << [
            Encounter.human_attribute_name(:id),
            MicroscopyResult.human_attribute_name(:id),
            Encounter.human_attribute_name(:status),
            Encounter.human_attribute_name(:testing_for),
            MicroscopyResult.human_attribute_name(:examined_by),
            MicroscopyResult.human_attribute_name(:sample_collected_at),
            MicroscopyResult.human_attribute_name(:result_at),
            MicroscopyResult.human_attribute_name(:specimen_type),
            MicroscopyResult.human_attribute_name(:test_result),
            MicroscopyResult.human_attribute_name(:appearance),
            MicroscopyResult.human_attribute_name(:result_status),
            MicroscopyResult.human_attribute_name(:feedback_message_id),
            MicroscopyResult.human_attribute_name(:comment)
          ]
          microscopy_results.map { |microscopy_result| add_csv_row(csv, microscopy_result) }
        end
      end

      protected

      def add_csv_row(csv, microscopy_result)
        csv << [
          microscopy_result.encounter.batch_id,
          microscopy_result.uuid,
          Extras::Select.find(Encounter.status_options, microscopy_result.encounter.status),
          Extras::Select.find(Encounter.testing_for_options, microscopy_result.encounter.testing_for),
          microscopy_result.examined_by,
          Extras::Dates::Format.datetime_with_time_zone(microscopy_result.sample_collected_at, :full_time),
          Extras::Dates::Format.datetime_with_time_zone(microscopy_result.result_at, :full_time),
          microscopy_result.specimen_type.blank? ? '' : I18n.t("test_results.index.specimen_type.#{microscopy_result.specimen_type}"),
          Extras::Select.find(MicroscopyResult.test_result_options, microscopy_result.test_result),
          Extras::Select.find(MicroscopyResult.visual_appearance_options, microscopy_result.appearance),
          Extras::Select.find(MicroscopyResult.status_options, microscopy_result.result_status),
          FeedbackMessages::Finder.find_text_from_patient_result(microscopy_result),
          microscopy_result.comment.to_s
        ]
      end
    end
  end
end
