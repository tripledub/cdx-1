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
            sampleId: sample_id(test_result),
            status: test_result.result_status,
            collectedAt: test_result.sample_collected_at,
            resultAt: test_result.result_at,
            viewLink: Rails.application.routes.url_helpers.test_results_path(test_result)
          }
        end
      end

      protected

      def assays(test_result)
      end

      def sample_id(test_result)
      end
    end
  end
end
