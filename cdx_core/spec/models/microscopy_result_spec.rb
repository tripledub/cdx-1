require 'spec_helper'

describe MicroscopyResult do
  let(:visual_appearance_options)  { ['blood', 'mucopurulent', 'saliva'] }
  let(:test_result_options)  { ['negative', '1to9', '1plus', '2plus', '3plus'] }


  context "validations" do
    it { should validate_inclusion_of(:appearance).in_array(visual_appearance_options) }
    it { should validate_inclusion_of(:test_result).in_array(test_result_options) }
  end
end
