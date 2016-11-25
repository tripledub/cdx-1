require 'spec_helper'

describe FeedbackMessages::Presenter do
  let(:institution)         { Institution.make }

  describe 'reject_reasons' do
    subject { described_class.reject_reasons(institution) }

    it 'returns a Hash of reject reassons' do
      expect(subject).to be_a(Hash)
      expect(subject.size).to eq(4)
    end

    it 'returns an array of localised rejection reasons' do
      expect(subject[:samplesCollected].size).to eq(2)
      expect(subject[:approval].size).to eq(1)
      expect(subject[:labTech].size).to eq(3)
      expect(subject[:finance].size).to eq(3)
    end

    it 'returns all elements correctly formatted' do
      feedback_message = FeedbackMessage.find(subject[:samplesCollected].first[:id])
      custom_translation = feedback_message.custom_translations.first
      expect(subject[:samplesCollected].first).to eq(
        id:   feedback_message.id,
        text: "#{custom_translation.text} (#{custom_translation.localisable.code})"
      )
    end
  end
end
