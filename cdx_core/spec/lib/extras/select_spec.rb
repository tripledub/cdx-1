require 'spec_helper'

describe Extras::Select do
  let(:select_options) do
    [
      ['first',  'First option'],
      ['second', 'Second option'],
      ['third',  'Third option'],
      ['fourth', 'Fourth option']
    ]
  end

  describe 'find' do
    it 'should return the first match in all options' do
      expect(described_class.find(select_options, 'second')).to eq('Second option')
    end

    it 'should return an empty string if no match is found' do
      expect(described_class.find(select_options, 'fifth')).to eq('')
    end
  end
end
