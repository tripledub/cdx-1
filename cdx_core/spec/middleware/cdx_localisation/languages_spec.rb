require 'spec_helper'

describe CdxLocalisation::Languages do
   context 'active locales' do
     it 'should return english as only core active local' do
       expect(described_class.active.first[1]).to eq 'en'
     end

     it 'should have 1 language' do
       expect(described_class.active.size).to eq 1
     end
   end
end
