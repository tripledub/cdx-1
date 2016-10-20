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
    end
  end
end
