require 'spec_helper'

describe MicroscopyResult do
  let(:visual_appearance_options)  { ['blood', 'mucopurulent', 'saliva'] }
  let(:test_result_options)  { ['negative', '1to9', '1plus', '2plus', '3plus'] }
  let(:result_status) { ['new', 'sample_collected', 'sample_received', 'pending_approval', 'rejected', 'completed'] }


  context "validations" do
    it { should validate_inclusion_of(:appearance).in_array(visual_appearance_options) }
    it { should validate_inclusion_of(:test_result).in_array(test_result_options) }
    it { should validate_inclusion_of(:result_status).in_array(result_status) }
  end
end
