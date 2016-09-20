require 'spec_helper'

describe TestBatches::Persistence do
  let(:encounter)         { Encounter.make test_batch: TestBatch.make }
  let(:test_batch)        { encounter.test_batch }
  let(:microscopy_result) { MicroscopyResult.make test_batch: test_batch }
  let(:dst_lpa_result)    { DstLpaResult.make test_batch: test_batch }
  let(:culture_result)    { CultureResult.make test_batch: test_batch }
  let(:tests_requested)   { 'microscopy|xpertmtb|culture_cformat_solid|drugsusceptibility1line_cformat_liquid|'}

  describe 'build_requested_tests' do
    it 'should build tests from string' do
      described_class.build_requested_tests(encounter.test_batch, tests_requested)

      expect(encounter.test_batch.patient_results.size).to eq(4)
    end

    it 'should create a valid batch of tests' do
      expect(encounter.test_batch.valid?).to be true
    end
  end

  describe 'update_status' do
    before :each do
      dst_lpa_result
      microscopy_result
    end

    it 'should set the status to new' do
      expect(test_batch.status).to eq('new')
    end

    it 'should set the status to in progress' do
      culture_result.update_attribute(:result_status, 'sample_received')
      test_batch.reload

      expect(test_batch.status).to eq('samples_received')
    end

    it 'should set the status to in progress' do
      culture_result.update_attribute(:result_status, 'completed')
      test_batch.reload

      expect(test_batch.status).to eq('in_progress')
    end

    it 'should set the status to in progress' do
      culture_result.update_attribute(:result_status, 'rejected')
      test_batch.reload

      expect(test_batch.status).to eq('in_progress')
    end

    it 'should set the status to closed' do
      microscopy_result.update_attribute(:result_status, 'rejected')
      dst_lpa_result.update_attribute(:result_status, 'rejected')
      culture_result.update_attribute(:result_status, 'rejected')
      test_batch.reload

      expect(test_batch.status).to eq('closed')
    end

    it 'should set the status to closed' do
      microscopy_result.update_attribute(:result_status, 'completed')
      dst_lpa_result.update_attribute(:result_status, 'completed')
      culture_result.update_attribute(:result_status, 'completed')
      test_batch.reload

      expect(test_batch.status).to eq('closed')
    end

    it 'should set the status to closed' do
      microscopy_result.update_attribute(:result_status, 'rejected')
      dst_lpa_result.update_attribute(:result_status, 'completed')
      culture_result.update_attribute(:result_status, 'completed')
      test_batch.reload

      expect(test_batch.status).to eq('closed')
    end
  end
end
