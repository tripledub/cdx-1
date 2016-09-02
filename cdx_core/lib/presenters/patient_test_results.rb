class Presenters::PatientTestResults
  class << self
    def patient_view(patient_results)
      patient_results.map do |result|
        case result.class.to_s
        when 'TestResult'
          format_test_result(result)
        when 'DstLpaResult'
          format_dst_lpa_result(result)
        when 'MicroscopyResult'
          format_microscopy_result(result)
        when 'CultureResult'
          format_culture_result(result)
        when 'XpertResult'
          format_xpert_result(result)
        end

      end
    end

    protected

    def format_test_result(test_result)
      {
        id:              test_result.uuid,
        name:            test_result.core_fields[TestResult::NAME_FIELD],
        date:            Extras::Dates::Format.datetime_with_time_zone(test_result.core_fields[TestResult::START_TIME_FIELD]),
        status:          test_result.core_fields[TestResult::STATUS_FIELD],
        viewLink:        Rails.application.routes.url_helpers.test_result_path(id: test_result.uuid)
      }
    end

    def format_xpert_result(xpert_result)
      {
        id:              xpert_result.uuid,
        name:            xpert_result.specimen_type,
        date:            Extras::Dates::Format.datetime_with_time_zone(xpert_result.sample_collected_on),
        status:          xpert_result.trace,
        viewLink:        Rails.application.routes.url_helpers.requested_test_xpert_result_path(requested_test_id: xpert_result.requested_test.id)
      }
    end

    def format_microscopy_result(microscopy_result)
      {
        id:              microscopy_result.uuid,
        name:            microscopy_result.specimen_type,
        date:            Extras::Dates::Format.datetime_with_time_zone(microscopy_result.sample_collected_on),
        status:          Extras::Select.find(MicroscopyResult.test_result_options, microscopy_result.test_result),
        viewLink:        Rails.application.routes.url_helpers.requested_test_microscopy_result_path(requested_test_id: microscopy_result.requested_test.id)
      }
    end

    def format_culture_result(culture_result)
      {
        id:              culture_result.uuid,
        name:            Extras::Select.find(CultureResult.media_options, culture_result.media_used),
        date:            Extras::Dates::Format.datetime_with_time_zone(culture_result.sample_collected_on),
        status:          Extras::Select.find(CultureResult.test_result_options, culture_result.test_result),
        viewLink:        Rails.application.routes.url_helpers.requested_test_culture_result_path(requested_test_id: culture_result.requested_test.id)
      }
    end

    def format_dst_lpa_result(dst_lpa_result)
      {
        id:              dst_lpa_result.uuid,
        name:            Extras::Select.find(DstLpaResult.method_options, dst_lpa_result.media_used),
        date:            Extras::Dates::Format.datetime_with_time_zone(dst_lpa_result.sample_collected_on),
        status:          dst_lpa_result.serial_number,
        viewLink:        Rails.application.routes.url_helpers.requested_test_dst_lpa_result_path(requested_test_id: dst_lpa_result.requested_test.id)
      }
    end
  end
end
