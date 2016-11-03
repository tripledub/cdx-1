module TestResults
  class Importer
    def initialize(test_result, parsed_message)
      @test_result = test_result
      @parsed_message = parsed_message
    end

    def import
      return unless test_core_available?
      add_assays
      add_results_code
    end

    protected

    def add_assays
      return unless @parsed_message['test']['core']['assays'].present?

      @parsed_message['test']['core']['assays'].each do |parsed_assay|
        @test_result.assay_results.new.tap do |assay|
          assay.name = parsed_assay['name']
          assay.condition = parsed_assay['condition']
          assay.result = parsed_assay['result']
          assay.quantitative_result = parsed_assay['quantitative_result'] if parsed_assay['quantitative_result'].present?
          assay.assay_data = parsed_assay
        end
      end
    end

    def add_results_code
      @test_result.result_name = @parsed_message['test']['core']['name'] if @parsed_message['test']['core']['name'].present?
      @test_result.result_status = @parsed_message['test']['core']['status'] if @parsed_message['test']['core']['status'].present?
      @test_result.result_type = @parsed_message['test']['core']['type'] if @parsed_message['test']['core']['type'].present?
      @test_result.sample_collected_at = parse_date(@parsed_message['test']['core']['start_time'])
      @test_result.result_at = parse_date(@parsed_message['test']['core']['end_time'])
    end

    def test_core_available?
      @parsed_message['test'].present? || @parsed_message['test']['core']['assays'].present?
    end

    def parse_date(result_date)
        Time.parse(result_date)
      rescue
        Time.now
      end
    end
  end
end
