module DstLpaResults
  # Presenter methods for dst/lpa tests
  class Presenter
    class << self
      def index_table(dst_lpa_results)
        dst_lpa_results.map do |dst_lpa_result|
          {
            id:                dst_lpa_result.uuid,
            sampleCollectedAt: Extras::Dates::Format.datetime_with_time_zone(dst_lpa_result.sample_collected_at, :full_time),
            examinedBy:        dst_lpa_result.examined_by,
            resultOn:          Extras::Dates::Format.datetime_with_time_zone(dst_lpa_result.result_at, :full_time),
            mediaUsed:         Extras::Select.find(DstLpaResult.method_options, dst_lpa_result.media_used),
            serialNumber:      dst_lpa_result.serial_number,
            resultH:           Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_h),
            resultR:           Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_r),
            resultE:           Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_e),
            resultS:           Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_s),
            resultAmk:         Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_amk),
            resultKm:          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_km),
            resultCm:          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_cm),
            resultFq:          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_fq),
            viewLink:          Rails.application.routes.url_helpers.encounter_dst_lpa_result_path(dst_lpa_result.encounter, dst_lpa_result)
          }
        end
      end

      def csv_query(dst_lpa_results)
        CSV.generate do |csv|
          csv << [
            Encounter.human_attribute_name(:id),
            Encounter.human_attribute_name(:status),
            Encounter.human_attribute_name(:testing_for),
            DstLpaResult.human_attribute_name(:id),
            DstLpaResult.human_attribute_name(:sample_collected_at),
            DstLpaResult.human_attribute_name(:examined_by),
            DstLpaResult.human_attribute_name(:result_at),
            DstLpaResult.human_attribute_name(:media_used),
            DstLpaResult.human_attribute_name(:serial_number),
            DstLpaResult.human_attribute_name(:results_h),
            DstLpaResult.human_attribute_name(:results_r),
            DstLpaResult.human_attribute_name(:results_e),
            DstLpaResult.human_attribute_name(:results_s),
            DstLpaResult.human_attribute_name(:results_amk),
            DstLpaResult.human_attribute_name(:results_km),
            DstLpaResult.human_attribute_name(:results_cm),
            DstLpaResult.human_attribute_name(:results_fq),
            DstLpaResult.human_attribute_name(:result_status),
            DstLpaResult.human_attribute_name(:feedback_message_id),
            DstLpaResult.human_attribute_name(:comment)
          ]
          dst_lpa_results.map { |dst_lpa_result| add_csv_row(csv, dst_lpa_result) }
        end
      end

      protected

      def add_csv_row(csv, dst_lpa_result)
        csv << [
          dst_lpa_result.encounter.batch_id,
          Extras::Select.find(Encounter.status_options, dst_lpa_result.encounter.status),
          Extras::Select.find(Encounter.testing_for_options, dst_lpa_result.encounter.testing_for),
          dst_lpa_result.uuid,
          Extras::Dates::Format.datetime_with_time_zone(dst_lpa_result.sample_collected_at, :full_time),
          dst_lpa_result.examined_by,
          Extras::Dates::Format.datetime_with_time_zone(dst_lpa_result.result_at, :full_time),
          Extras::Select.find(DstLpaResult.method_options, dst_lpa_result.media_used),
          dst_lpa_result.serial_number,
          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_h),
          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_r),
          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_e),
          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_s),
          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_amk),
          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_km),
          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_cm),
          Extras::Select.find(DstLpaResult.dst_lpa_options, dst_lpa_result.results_fq),
          Extras::Select.find(DstLpaResult.status_options, dst_lpa_result.result_status),
          FeedbackMessages::Finder.find_text_from_patient_result(dst_lpa_result),
          dst_lpa_result.comment.to_s
        ]
      end
    end
  end
end
