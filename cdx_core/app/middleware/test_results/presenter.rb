module TestResults
  # Presenter for test results
  class Presenter
    class << self
      def index_table(test_results)
        test_results.map do |test_result|
          {
            id: test_result.id,
            name: test_result.result_name,
            assays: Assays::Presenter.all_results(test_result),
            siteName: Sites::Presenter.site_name(test_result.site),
            deviceName: Devices::Presenter.device_name_and_serial_number(test_result.device),
            sampleId: SampleIdentifiers::Presenter.orphan_sample_id(test_result),
            status: localise_status(test_result),
            collectedAt: Extras::Dates::Format.datetime_with_time_zone(test_result.sample_collected_at),
            resultAt: Extras::Dates::Format.datetime_with_time_zone(test_result.result_at),
            viewLink: Rails.application.routes.url_helpers.test_result_path(test_result)
          }
        end
      end

      protected

      def localise_status(test_result)
        return '' unless test_result.result_status.present?

        I18n.t('select.test_results.result_status.' + test_result.result_status)
      end
    end
  end
end
