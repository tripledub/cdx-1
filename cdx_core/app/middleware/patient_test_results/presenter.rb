module PatientTestResults
  # Presenter methods for patient test results
  class Presenter
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
          name:            test_result.device.name,
          date:            Extras::Dates::Format.datetime_with_time_zone(test_result.core_fields[TestResult::START_TIME_FIELD], :full_time),
          status:          test_result.core_fields[TestResult::STATUS_FIELD].blank? ? "" : I18n.t("patient_test_results.status.#{test_result.core_fields[TestResult::STATUS_FIELD]}"),
          viewLink:        Rails.application.routes.url_helpers.test_result_path(id: test_result.uuid)
        }
      end

      def format_xpert_result(xpert_result)
        {
          id:              xpert_result.uuid,
          name:            I18n.t('patient_test_results.index.xpert_result'),
          date:            Extras::Dates::Format.datetime_with_time_zone(xpert_result.sample_collected_at, :full_time),
          status:          xpert_result.result_status.blank? ? "" : I18n.t("patient_test_results.status.#{xpert_result.result_status}"),
          viewLink:        Rails.application.routes.url_helpers.encounter_xpert_result_path(xpert_result.encounter, xpert_result)
        }
      end

      def format_microscopy_result(microscopy_result)
        {
          id:              microscopy_result.uuid,
          name:            I18n.t('patient_test_results.index.microscopy_result'),
          date:            Extras::Dates::Format.datetime_with_time_zone(microscopy_result.sample_collected_at, :full_time),
          status:          microscopy_result.result_status.blank? ? "" : I18n.t("patient_test_results.status.#{microscopy_result.result_status}"),
          viewLink:        Rails.application.routes.url_helpers.encounter_microscopy_result_path(microscopy_result.encounter, microscopy_result)
        }
      end

      def format_culture_result(culture_result)
        {
          id:              culture_result.uuid,
          name:            I18n.t('patient_test_results.index.culture_result'),
          date:            Extras::Dates::Format.datetime_with_time_zone(culture_result.sample_collected_at, :full_time),
          status:          culture_result.result_status.blank? ? "" : I18n.t("patient_test_results.status.#{culture_result.result_status}"),
          viewLink:        Rails.application.routes.url_helpers.encounter_culture_result_path(culture_result.encounter, culture_result)
        }
      end

      def format_dst_lpa_result(dst_lpa_result)
        {
          id:              dst_lpa_result.uuid,
          name:            I18n.t('patient_test_results.index.dst_lpa_result'),
          date:            Extras::Dates::Format.datetime_with_time_zone(dst_lpa_result.sample_collected_at, :full_time),
          status:          dst_lpa_result.result_status.blank? ? "" : I18n.t("patient_test_results.status.#{dst_lpa_result.result_status}"),
          viewLink:        Rails.application.routes.url_helpers.encounter_dst_lpa_result_path(dst_lpa_result.encounter, dst_lpa_result)
        }
      end
    end
  end
end
