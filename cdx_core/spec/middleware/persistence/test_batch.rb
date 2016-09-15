require 'spec_helper'

describe Persistence::TestBatch do
  let(:tests_requested) { 'microscopy|xpertmtb|culture_cformat_solid|drugsusceptibility1line_cformat_liquid|'}
  describe 'build_requested_tests' do
    it 'should build tests from string' do
      described_class.build_requested_tests(tests_requested)

      expect(test_batch.patient_results.size).to eq(4)
    end
  end
end
