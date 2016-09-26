require 'spec_helper'

describe CultureResult do
  let(:media_options)  { ['solid', 'liquid'] }
  let(:test_result_options)  { ['negative', '1to9', '1plus', '2plus', '3plus', 'ntm', 'contaminated'] }
  let(:result_status) { ['new', 'sample_collected', 'sample_received', 'pending_approval', 'rejected', 'completed'] }

  context "validations" do
    it { should validate_presence_of(:sample_collected_on).on(:update) }
    it { should validate_presence_of(:examined_by).on(:update) }
    it { should validate_presence_of(:result_on).on(:update) }
    it { should validate_presence_of(:media_used).on(:update) }
    it { should validate_presence_of(:serial_number).on(:update) }
    it { should validate_presence_of(:test_result).on(:update) }
    it { should validate_inclusion_of(:media_used).in_array(media_options) }
    it { should validate_inclusion_of(:test_result).in_array(test_result_options) }
    it { should validate_inclusion_of(:result_status).in_array(result_status) }
  end
end
