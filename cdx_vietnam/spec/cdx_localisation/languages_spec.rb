require 'spec_helper'

describe CdxLocalisation::Languages do
   context 'active locales' do
     it 'should return vietnam as active language' do
       expect(described_class.active.last[1]).to eq 'vi'
     end

     it 'should have 2 languages' do
       expect(described_class.active.size).to eq 2
     end
   end
end
