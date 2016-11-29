require 'spec_helper'

describe Extras::Dates::Format do
  describe "patient_birth_date_on" do
    before :each do
      Timecop.freeze(Time.local(2016, 6, 17, 12, 0, 0))
    end

    context 'if person is more than 1 year old' do
      it 'should return the date and the number of years' do
        expect(described_class.patient_birth_date(Date.new(1972, 3, 26))).to eq('26/03/1972 - 44y/o.')
      end
    end

    context 'if person is less than 1 year old' do
      it 'should return the date and the number of months' do
        expect(described_class.patient_birth_date(Date.new(2015, 11, 26))).to eq('26/11/2015 - 7m/o.')
      end
    end

    after :each do
      Timecop.return
    end
  end
end
