require 'spec_helper'

describe TestOrders::Status do
  let(:user)              { User.make }
  let(:institution)       { user.institutions.make }
  let(:patient)           { Patient.make institution: institution }
  let(:encounter)         { Encounter.make patient: patient }
  let(:microscopy_result) { MicroscopyResult.make encounter: encounter }
  let(:dst_lpa_result)    { DstLpaResult.make encounter: encounter }
  let(:culture_result)    { CultureResult.make encounter: encounter }
  let(:tests_requested)   { 'microscopy|xpertmtb|culture_cformat_solid|drugsusceptibility1line_cformat_liquid|' }
  let(:feedback_message)  { FeedbackMessage.make institution: institution }
  let(:update_params) do
    {
      comment: 'New comment for the encounter',
      feedback_message_id: feedback_message.id,
      status: 'financed'
    }
  end

  describe 'update_status' do
    before :each do
      User.current = user
      dst_lpa_result
      microscopy_result
    end

    it 'should set the status to new' do
      expect(encounter.status).to eq('new')
    end

    it 'should set the status to sample received' do
      culture_result.update_attribute(:result_status, 'allocated')
      encounter.reload

      expect(encounter.status).to eq('samples_received')
    end

    it 'should set the status to in progress' do
      culture_result.update_attribute(:result_status, 'completed')
      encounter.reload

      expect(encounter.status).to eq('in_progress')
    end

    it 'should set the status to in progress' do
      culture_result.update_attribute(:result_status, 'rejected')
      encounter.reload

      expect(encounter.status).to eq('in_progress')
    end

    it 'should set the status to closed' do
      microscopy_result.update_attribute(:result_status, 'rejected')
      dst_lpa_result.update_attribute(:result_status, 'rejected')
      culture_result.update_attribute(:result_status, 'rejected')
      encounter.reload

      expect(encounter.status).to eq('closed')
    end

    it 'should set the status to closed' do
      microscopy_result.update_attribute(:result_status, 'completed')
      dst_lpa_result.update_attribute(:result_status, 'completed')
      culture_result.update_attribute(:result_status, 'completed')
      encounter.reload

      expect(encounter.status).to eq('closed')
    end

    it 'should set the status to closed' do
      microscopy_result.update_attribute(:result_status, 'rejected')
      dst_lpa_result.update_attribute(:result_status, 'completed')
      culture_result.update_attribute(:result_status, 'completed')
      encounter.reload

      expect(encounter.status).to eq('closed')
    end
  end

  describe 'update_and_comment' do
    before :each do
      User.current = user
      described_class.update_and_comment(encounter, update_params)
      encounter.reload
    end

    it 'should update status of a test order' do
      expect(encounter.status).to eq('financed')
    end

    it 'should update the comment of a test order' do
      expect(encounter.feedback_message).to eq(feedback_message)
    end

    it 'should update the feedback message of a test order' do
      expect(encounter.comment).to eq('New comment for the encounter')
    end
  end
end
