require 'spec_helper'
require 'policy_spec_helper'

describe PatientResults::Persistence do
  let(:user)              { User.make }
  let(:institution)       { user.institutions.make }
  let(:patient)           { Patient.make institution: institution }
  let(:encounter)         { Encounter.make institution: institution, patient: patient }
  let(:microscopy_result) { MicroscopyResult.make encounter: encounter }
  let(:culture_result)    { CultureResult.make encounter: encounter }
  let(:feedback_message)  { FeedbackMessage.make institution: institution }
  let(:sample_ids)        { { microscopy_result.id.to_s => '8778', culture_result.id.to_s => 'Random Id' } }
  let(:tests_requested)   { 'microscopy|xpertmtb|culture_cformat_solid|drugsusceptibility1line_cformat_liquid|' }

  before :each do
    User.current = user
  end

  describe 'build_requested_tests' do
    it 'should build tests from string' do
      described_class.build_requested_tests(encounter, tests_requested)

      expect(encounter.patient_results.count).to eq(4)
    end

    it 'should create a valid batch of tests' do
      expect(encounter.valid?).to be true
    end
  end

  describe 'results_not_financed' do
    before :each do
      culture_result
      microscopy_result
      described_class.results_not_financed(encounter)
      culture_result.reload
      microscopy_result.reload
    end

    it 'should change all results status to rejected' do
      expect(microscopy_result.result_status).to eq('rejected')
      expect(culture_result.result_status).to eq('rejected')
    end

    it 'should update result_at' do
      expect(microscopy_result.result_at).to be
      expect(culture_result.result_at).to be
    end

    it 'should change feedback message to Not financed' do
      feedback_message = FeedbackMessages::Finder.patient_result_not_financed(institution)
      expect(microscopy_result.feedback_message).to eq(feedback_message)
      expect(culture_result.feedback_message).to eq(feedback_message)
    end
  end

  describe 'update_status' do
    context 'status' do
      let(:patient_result) { { result_status: 'rejected' } }

      before :each do
        described_class.update_status(microscopy_result, patient_result)
      end

      it 'should update result status to rejected' do
        expect(microscopy_result.result_status).to eq('rejected')
      end

      it 'should update result_at' do
        expect(microscopy_result.result_at).to be
      end
    end

    context 'comment' do
      context 'comment with content' do
        let(:patient_result) { { comment: 'New comment added' } }

        before :each do
          described_class.update_status(microscopy_result, patient_result)
        end

        it 'should update the comment' do
          expect(microscopy_result.comment).to eq('New comment added')
        end
      end

      context 'blank comment' do
        let(:patient_result) { { comment: '' } }

        before :each do
          microscopy_result.update_attribute(:comment, 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor')
          described_class.update_status(microscopy_result, patient_result)
        end

        it 'should not update the comment' do
          expect(microscopy_result.comment).to eq('Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor')
        end
      end

      context 'wrong update' do
        let(:patient_result) { { result_status: 'rejected' } }

        it 'should return an error message' do
          PatientResults::Persistence.stub(:update_patient_result).and_return(false)
          _message, status = described_class.update_status(microscopy_result, patient_result)

          expect(status).to eq(:unprocessable_entity)
        end
      end
    end

    context 'feedback' do
      let(:patient_result) { { feedback_message_id: feedback_message.id } }

      before :each do
        described_class.update_status(microscopy_result, patient_result)
      end

      it 'should update the feedback message' do
        expect(microscopy_result.feedback_message).to eq(feedback_message)
      end
    end

    context 'status is allocated' do
      it 'should update result status to allocated' do
        described_class.update_status(microscopy_result, result_status: 'allocated')

        expect(microscopy_result.result_status).to eq('allocated')
      end
    end

    context 'status is completed' do
      context 'user with permission' do
        it 'should update result status to completed' do
          described_class.update_status(microscopy_result, result_status: 'completed')

          expect(microscopy_result.result_status).to eq('completed')
        end
      end

      context 'user with no permission' do
        let(:user2) { User.make }

        it 'should update result status to completed' do
          User.current = user2
          grant user, user2, Institution, Policy::Actions::READ_INSTITUTION

          described_class.update_status(microscopy_result, result_status: 'completed')

          expect(microscopy_result.result_status).to_not eq('completed')
        end
      end
    end
  end

  describe 'update_result' do
    it 'should set result status to pending approval' do
      described_class.update_result(
        microscopy_result,
        { result_status: 'completed', comment: 'New comment added' },
        'Microscopy updated'
      )

      expect(microscopy_result.result_status).to eq('pending_approval')
    end
  end
end
