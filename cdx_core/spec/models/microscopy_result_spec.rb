require 'spec_helper'

describe MicroscopyResult do
  let(:visual_appearance_options)  { ['blood', 'mucopurulent', 'saliva'] }
  let(:test_result_options)  { ['negative', '1to9', '1plus', '2plus', '3plus'] }

  context "validations" do
    it { should belong_to(:requested_test) }
    it { should validate_presence_of(:requested_test_id) }
    it { should validate_presence_of(:sample_collected_on) }
    it { should validate_presence_of(:specimen_type) }
    it { should validate_presence_of(:serial_number) }
    it { should validate_presence_of(:appearance) }
    it { should validate_presence_of(:examined_by) }
    it { should validate_presence_of(:result_on) }
    it { should validate_presence_of(:test_result) }
    it { should validate_inclusion_of(:appearance).in_array(visual_appearance_options) }
    it { should validate_inclusion_of(:test_result).in_array(test_result_options) }
  end
end
