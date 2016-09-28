require 'spec_helper'

describe Audit::TextTranslator do
  describe 'localise' do
    it 'should localise text inside t{}' do
      expect(described_class.localise('before t{patients.show.episode_empty_header} after')).to eq('before No medical history after')
    end
  end
end
