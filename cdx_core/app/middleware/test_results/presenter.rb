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
            sampleId: test_result.sample_identifiers.map(&:entity_id).join(' / '),
            status: localise_status(test_result),
            collectedAt: Extras::Dates::Format.datetime_with_time_zone(test_result.sample_collected_at, :full_time),
            resultAt: Extras::Dates::Format.datetime_with_time_zone(test_result.result_at, :full_time),
            viewLink: Rails.application.routes.url_helpers.test_result_path(test_result)
          }
        end
      end

      def csv_query(test_results)
        CSV.generate do |csv|
          csv << [
            TestResult.human_attribute_name(:test_id),
            TestResult.human_attribute_name(:sample_collected_at),
            TestResult.human_attribute_name(:result_at),
            TestResult.human_attribute_name(:result_name),
            TestResult.human_attribute_name(:device_id),
            TestResult.human_attribute_name(:site_id),
            TestResult.human_attribute_name(:sample_identifier_id),
            TestResult.human_attribute_name(:result_status),
            TestResult.human_attribute_name(:result_type),
          ]
          test_results.map { |test_result| add_csv_row(csv, test_result) }
        end
      end

      protected

      def add_csv_row(csv, test_result)
        csv << [
          test_result.test_id,
          Extras::Dates::Format.datetime_with_time_zone(test_result.sample_collected_at, :full_time),
          Extras::Dates::Format.datetime_with_time_zone(test_result.result_at, :full_time),
          test_result.result_name,
          Devices::Presenter.device_name_and_serial_number(test_result.device),
          Sites::Presenter.site_name(test_result.site),
          test_result.sample_identifiers.map(&:entity_id).join(' / '),
          localise_status(test_result),
          test_result.result_type
        ]
      end

      def localise_status(test_result)
        return '' unless test_result.result_status.present?

        I18n.t('select.test_results.result_status.' + test_result.result_status)
      end
    end
  end
end
