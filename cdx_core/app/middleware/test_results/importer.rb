module TestResults
  class Importer
    def initialize(test_result)
      @test_result = test_result
    end

    def import_message(parsed_message)
      create_assays(parsed_message)
    end

    protected

    def create_assays(parsed_message)
      return if !parsed_message['test'].present? || !parsed_message['test']['core']['assays'].present? || !parsed_message['test']['core']['assays'].present?

      parsed_assays = parsed_message['test']['core']['assays']
      parsed_assays.each do |parsed_assay|
        @test_result.assay_results.new do |assay|
          assay.name = parsed_assay['name']
          assay.condition = parsed_assay['condition']
          assay.result = parsed_assay['result']
          assay.quantitative_result parsed_assay['quantitative_result'] if parsed_assay['quantitative_result'].present?
          assay.assay_data = parsed_assay
        end
      end
    end
  end
end
