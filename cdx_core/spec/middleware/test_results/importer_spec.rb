require 'spec_helper'

describe TestResults::Importer do
  let(:test_result) { TestResult.make }
  let(:message) {
    {
      "test" => {
        "core" => {
          "id" => 'test_id',
          "start_time" => 3.days.from_now,
          "name" => "Test name",
          "status" => "closed",
          "type" => "Put sample on machine, press play.",
          "assays" => [
            { "name" => "mtb", "condition" => "mtb", "result" => "positive"},
            { "name" => "ebola", "condition" => "eb", "result" => "positive"},
            { "name" => "mtb", "condition" => "mtb", "result" => "negative"}
          ]
        }
      }
    }
  }
  describe 'import' do
    before :each do
      described_class.new(test_result, message).import
    end

    it 'should add result_name to test_result' do
      expect(test_result.result_name).to eq('Test name')
    end

    it 'should add result_status to test_result' do
      expect(test_result.result_status).to eq('closed')
    end

    it 'should add result_type to test_result' do
      expect(test_result.result_type).to eq('Put sample on machine, press play.')
    end

    it 'should add assays to test_result' do
      expect(test_result.assay_results.size).to eq(3)
    end
  end
end
