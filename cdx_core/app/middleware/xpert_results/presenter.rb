module XpertResults
  # Presenter methods for xpert results
  class Presenter
    class << self
      def index_table(xpert_results)
        xpert_results.map do |xpert_result|
          {
            id:                xpert_result.uuid,
            sampleCollectedAt: Extras::Dates::Format.datetime_with_time_zone(xpert_result.sample_collected_at, :full_time),
            examinedBy:        xpert_result.examined_by,
            resultOn:          Extras::Dates::Format.datetime_with_time_zone(xpert_result.result_at, :full_time),
            tuberculosis:      Extras::Select.find(XpertResult.tuberculosis_options, xpert_result.specimen_type),
            rifampicin:        Extras::Select.find(XpertResult.rifampicin_options, xpert_result.serial_number),
            trace:             Extras::Select.find(XpertResult.trace_options, xpert_result.trace),
            viewLink:          Rails.application.routes.url_helpers.encounter_xpert_result_path(xpert_result.encounter, xpert_result)
          }
        end
      end

      def csv_query(xpert_results)
        CSV.generate do |csv|
          csv << [
            XpertResult.human_attribute_name(:id),
            XpertResult.human_attribute_name(:sample_collected_at),
            XpertResult.human_attribute_name(:examined_by),
            XpertResult.human_attribute_name(:result_at),
            XpertResult.human_attribute_name(:specimen_type),
            XpertResult.human_attribute_name(:serial_number),
            XpertResult.human_attribute_name(:trace),
            XpertResult.human_attribute_name(:result_status),
            XpertResult.human_attribute_name(:feedback_message_id),
            XpertResult.human_attribute_name(:comment)
          ]
          xpert_results.map { |xpert_result| add_csv_row(csv, xpert_result) }
        end
      end

      protected

      def add_csv_row(csv, xpert_result)
        csv << [
          xpert_result.uuid,
          Extras::Dates::Format.datetime_with_time_zone(xpert_result.sample_collected_at, :full_time),
          xpert_result.examined_by,
          Extras::Dates::Format.datetime_with_time_zone(xpert_result.result_at, :full_time),
          Extras::Select.find(XpertResult.tuberculosis_options, xpert_result.specimen_type),
          Extras::Select.find(XpertResult.rifampicin_options, xpert_result.serial_number).to_s,
          Extras::Select.find(XpertResult.trace_options, xpert_result.trace),
          Extras::Select.find(XpertResult.status_options, xpert_result.result_status),
          FeedbackMessages::Finder.find_text_from_patient_result(xpert_result),
          xpert_result.comment.to_s
        ]
      end
    end
  end
end
