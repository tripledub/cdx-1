require 'spec_helper'

describe DstLpaResult do
  context "validations" do
    it { should belong_to(:requested_test) }
    it { should validate_presence_of(:sample_collected_on) }
    it { should validate_presence_of(:examined_by) }
    it { should validate_presence_of(:result_on) }
    it { should validate_presence_of(:specimen_type) }
    it { should validate_presence_of(:serial_number) }
    it { should validate_presence_of(:results_h) }
    it { should validate_presence_of(:results_r) }
    it { should validate_presence_of(:results_e) }
    it { should validate_presence_of(:results_s) }
    it { should validate_presence_of(:results_amk) }
    it { should validate_presence_of(:results_km) }
    it { should validate_presence_of(:results_cm) }
    it { should validate_presence_of(:results_fq) }
  end
end
