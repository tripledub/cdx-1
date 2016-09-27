require 'spec_helper'
require 'policy_spec_helper'

describe PatientResults::Persistence do
  let(:user)              { User.make }
  let!(:institution)      { user.institutions.make }
  let(:patient)           { Patient.make institution: institution }
  let(:encounter)         { Encounter.make institution: institution, patient: patient }
  let(:test_batch)        { TestBatch.make encounter: encounter, institution: institution }
  let(:microscopy_result) { MicroscopyResult.make test_batch: test_batch }
  let(:culture_result)    { CultureResult.make test_batch: test_batch }
  let(:feedback_message)  { FeedbackMessage.make institution: institution }
  let(:sample_ids)        { { microscopy_result.id.to_s => '8778', culture_result.id.to_s => 'Random Id' } }

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
    context 'status is rejected' do
      let(:patient_result) { { result_status: 'rejected', comment: 'New comment added', feedback_message_id: feedback_message.id } }

      before :each do
        described_class.update_status(microscopy_result, patient_result, user)
      end

      it 'should update result status to rejected' do
        expect(microscopy_result.result_status).to eq('rejected')
      end

      it 'should update the comment' do
        expect(microscopy_result.comment).to eq('New comment added')
      end

      it 'should update the feedback message' do
        expect(microscopy_result.feedback_message).to eq(feedback_message)
      end
    end

    context 'status is sample received' do
      it 'should update result status to sample received' do
        described_class.update_status(microscopy_result, { result_status: 'sample_received' }, user)

        expect(microscopy_result.result_status).to eq('sample_received')
      end
    end

    context 'status is completed' do
      context 'user with permission' do
        it 'should update result status to completed' do
          described_class.update_status(microscopy_result, { result_status: 'completed' }, user)

          expect(microscopy_result.result_status).to eq('completed')
        end
      end

      context 'user with no permission' do
        let(:user2) { User.make }

        it 'should update result status to completed' do
          grant user, user2, Institution, Policy::Actions::READ_INSTITUTION

          described_class.update_status(microscopy_result, { result_status: 'completed' }, user2)

          expect(microscopy_result.result_status).to_not eq('completed')
        end
      end
    end
  end

  describe 'update_result' do
    it 'should set result status to pending approval' do
      described_class.update_result(
        microscopy_result,
        { result_status: 'completed', comment: 'New comment added' }, user, 'Microscopy updated'
      )

      expect(microscopy_result.result_status).to eq('pending_approval')
    end
  end
end
