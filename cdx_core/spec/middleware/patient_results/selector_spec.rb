require 'spec_helper'

describe PatientResults::Selector do
  describe 'instance_from_string' do
    it 'should return a microscopy instance' do
      expect(described_class.instance_from_string('microscopy')).to be_an_instance_of(MicroscopyResult)
    end

    it 'should return a culture instance' do
      expect(described_class.instance_from_string('culture_cformat_solid')).to be_an_instance_of(CultureResult)
    end

    it 'should return a xpert instance' do
      expect(described_class.instance_from_string('xpertmtb')).to be_an_instance_of(XpertResult)
    end

    it 'should return a dst/lpa instance' do
      expect(described_class.instance_from_string('drugsusceptibility1line_cformat_liquid')).to be_an_instance_of(DstLpaResult)
    end
  end
end
