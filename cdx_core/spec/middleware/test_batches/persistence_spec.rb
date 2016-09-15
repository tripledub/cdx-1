require 'spec_helper'

describe TestBatches::Persistence do
  let(:encounter) { Encounter.make }
  let(:tests_requested) { 'microscopy|xpertmtb|culture_cformat_solid|drugsusceptibility1line_cformat_liquid|'}

  describe 'build_requested_tests' do
    it 'should build tests from string' do
      described_class.build_requested_tests(encounter.test_batch, tests_requested)

      expect(encounter.test_batch.patient_results.size).to eq(4)
    end

    it 'should create a valid batch of tests' do
      expect(encounter.test_batch.valid?).to be true
    end
  end
end
