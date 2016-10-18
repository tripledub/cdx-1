require 'spec_helper'
require 'policy_spec_helper'

describe Samples::Persistence do
  let(:user)              { User.make }
  let(:institution)       { user.institutions.make }
  let(:patient)           { Patient.make institution: institution }
  let(:encounter)         { Encounter.make institution: institution, patient: patient }
  let(:microscopy_result) { MicroscopyResult.make encounter: encounter }
  let(:culture_result)    { CultureResult.make encounter: encounter }
  let(:feedback_message)  { FeedbackMessage.make institution: institution }
  let(:sample_identifier) { SampleIdentifier.make cpd_id_sample: '8778' }
  let(:sample_ids)        { ['8778', 'Random Id'] }

  before :each do
    User.current = user
  end

  describe 'collect_sample_ids' do
    context 'when data is valid' do
      before :each do
        described_class.collect_sample_ids(encounter, sample_ids)
        encounter.reload
      end

      it 'should populate serial number with lab Id.' do
        expect(encounter.samples.first.sample_identifiers.first.cpd_id_sample).to eq('8778')
      end

      it 'should populate serial number with lab Id.' do
        expect(encounter.samples.last.sample_identifiers.first.cpd_id_sample).to eq('Random Id')
      end

      it 'should update encounter status to samples collected' do
        expect(encounter.status).to eq('samples_collected')
      end
    end

    context 'sample id exists but has been assigned to a test result' do
      before :each do
        microscopy_result.update_attribute(:sample_identifier_id, sample_identifier.id)
        described_class.collect_sample_ids(encounter, ['8778'])
      end

      it 'should create a new sample id' do
        expect(SampleIdentifier.where('cpd_id_sample = ?', '8778').count).to eq(2)
      end
    end
  end

  context 'when data is invalid' do
    before :each do
      described_class.collect_sample_ids(encounter, sample_ids)
      encounter.reload
    end

    it 'should return an error message' do
      expect(described_class.collect_sample_ids(encounter, ['8778']).first).to eq('Sample: 8778 has already been added to the test order.')
    end
  end
end
