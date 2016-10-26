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

      def csv_query(culture_results)
        CSV.generate do |csv|
          csv << [
            MicroscopyResult.human_attribute_name(:id),
            MicroscopyResult.human_attribute_name(:sample_collected_at),
            MicroscopyResult.human_attribute_name(:examined_by),
            MicroscopyResult.human_attribute_name(:result_at),
            MicroscopyResult.human_attribute_name(:specimen_type),
            MicroscopyResult.human_attribute_name(:serial_number),
            MicroscopyResult.human_attribute_name(:trace),
            MicroscopyResult.human_attribute_name(:result_status),
            MicroscopyResult.human_attribute_name(:feedback_message_id),
            MicroscopyResult.human_attribute_name(:comment)
          ]
          culture_results.map { |culture_result| add_csv_row(csv, culture_result) }
        end
      end

      protected

      def add_csv_row(csv, culture_result)
        csv << [
          culture_result.uuid,
          Extras::Dates::Format.datetime_with_time_zone(culture_result.sample_collected_at, :full_time),
          culture_result.examined_by,
          Extras::Dates::Format.datetime_with_time_zone(culture_result.result_at, :full_time),
          Extras::Select.find(CultureResult.media_options, culture_result.media_used),
          culture_result.serial_number,
          Extras::Select.find(CultureResult.test_result_options, culture_result.test_result),
          Extras::Select.find(MicroscopyResult.status_options, culture_result.result_status),
          FeedbackMessages::Finder.find_text_from_patient_result(culture_result),
          culture_result.comment.to_s
        ]
      end
    end
  end
end
