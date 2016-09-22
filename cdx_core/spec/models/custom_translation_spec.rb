require 'spec_helper'

describe CustomTranslation do
  describe 'associations' do
    it { should belong_to(:localisable) }
  end
end
