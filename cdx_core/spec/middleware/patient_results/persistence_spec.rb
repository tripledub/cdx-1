require 'spec_helper'

describe PatientResults::Persistence do
  let(:institution)       { Institution.make }
  let(:patient)           { Patient.make institution: institution }
  let(:encounter)         { Encounter.make institution: institution, patient: patient }
  let(:test_batch)        { TestBatch.make encounter: encounter, institution: institution }
  let(:microscopy_result) { MicroscopyResult.make test_batch: test_batch }
  let(:culture_result)    { CultureResult.make test_batch: test_batch }
  let(:sample_ids) {
    { microscopy_result.id.to_s => '8778', culture_result.id.to_s => 'Random Id' }
  }

  describe 'collect_sample_ids' do
    before :each do
      described_class.collect_sample_ids(test_batch, sample_ids)
    end

    it 'should populate serial number with lab Id.' do
      expect(test_batch.patient_results.first.serial_number).to eq('8778')
    end

    it 'should populate serial number with lab Id.' do
      expect(test_batch.patient_results.last.serial_number).to eq('Random Id')
    end

    it 'should update test batch status to samples collected' do
      expect(test_batch.status).to eq('samples_collected')
    end
  end

  describe 'update_status' do
    let(:patient_result) { { result_status: 'rejected', comment: 'New comment added' } }

    it 'should update result status to rejected' do
      described_class.update_status(microscopy_result, { result_status: 'rejected', comment: 'New comment added' })

      expect(microscopy_result.result_status).to eq('rejected')
    end

    it 'should update result status to completed' do
      described_class.update_status(microscopy_result, { result_status: 'completed', comment: 'New comment added' })

      expect(microscopy_result.result_status).to eq('completed')
    end

    it 'should update the comment' do
      described_class.update_status(microscopy_result, { result_status: 'completed', comment: 'New comment added' })

      expect(microscopy_result.comment).to eq('New comment added')
    end
  end
end
