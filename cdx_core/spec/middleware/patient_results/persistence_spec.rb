require 'spec_helper'

describe PatientResults::Persistence do
  let(:test_batch) { TestBatch.make }
  let(:microscopy_result) { MicroscopyResult.make test_batch: test_batch }
  let(:sample_ids) {
    [
      { 'id' => microscopy_result.id, 'sample' => '8778' }
    ]
  }

  describe 'collect_sample_ids' do
    it 'should populate serial number with lab Id.' do
      described_class.collect_sample_ids(test_batch, sample_ids)

      expect(test_batch.patient_results.first.serial_number).to eq('8778')
    end
  end
end
