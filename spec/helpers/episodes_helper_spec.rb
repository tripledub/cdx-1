require 'spec_helper'

RSpec.describe EpisodesHelper, type: :helper do
  describe 'outcome_options' do
    it 'returns a JSON object of episode outcomes' do
      expect(helper.outcome_options).to be_a(Array)
    end
  end
end
