require 'spec_helper'

describe PatientResult do
  let(:encounter)   { Encounter.make }
  let(:test_batch)  { TestBatch.make encounter: encounter }
  let(:test_result) { MicroscopyResult.make created_at: 3.days.ago, test_batch: test_batch }

  context "validations" do
    it { should belong_to(:requested_test) }

    it { should belong_to(:test_batch) }
  end

  context 'after_save' do
    it 'should update status' do
      expect(TestBatches::Persistence).to receive(:update_status).with(test_result.test_batch)

      test_result.save
    end

    context 'if status is updated' do
      it 'should set completed_at to current time if status is completed' do
        test_result.update_attribute(:result_status, 'completed')

        expect(test_result.completed_at).to be
      end

      it 'should not update completed_at' do
        test_result.update_attribute(:result_status, 'rejected')

        expect(test_result.completed_at).to_not be
      end
    end
  end

  describe 'turnaround time' do
    context 'when the test is incomplete' do
      it 'says incomplete' do
        expect(test_result.turnaround).to eq(I18n.t('patient_result.incomplete'))
      end
    end

    context 'when the test is closed' do
      it 'gives the turnaround time in words' do
        test_result.update_attribute(:result_status, 'completed')
        test_result.reload

        expect(test_result.turnaround).to eq('3 days')
      end
    end
  end
end
