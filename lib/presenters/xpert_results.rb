class Presenters::XpertResults
  class << self
    def index_table(xpert_results)
      xpert_results.map do |xpert_result|
        {
          id:                xpert_result.uuid,
          sampleCollectedOn: Extras::Dates::Format.datetime_with_time_zone(xpert_result.sample_collected_on),
          examinedBy:        xpert_result.examined_by,
          resultOn:          Extras::Dates::Format.datetime_with_time_zone(xpert_result.result_on),
          tuberculosis:      Extras::Select.find(XpertResult.tuberculosis_options, xpert_result.specimen_type),
          rifampicin:        Extras::Select.find(XpertResult.rifampicin_options, xpert_result.serial_number),
          trace:             Extras::Select.find(XpertResult.trace_options, xpert_result.trace),
          viewLink:          Rails.application.routes.url_helpers.requested_test_microscopy_result_path(requested_test_id: xpert_result.requested_test.id)
        }
      end
    end
  end
end
