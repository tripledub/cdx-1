require 'spec_helper'

describe CultureResult do
  let(:media_options) { %w(solid liquid) }
  let(:test_result_options) { %w(negative 1to9 1plus 2plus 3plus ntm contaminated) }
  let(:result_status) { %w(new sample_collected allocated pending_approval rejected completed) }

  context "validations" do
    it { should validate_presence_of(:sample_collected_at).on(:update) }
    it { should validate_presence_of(:examined_by).on(:update) }
    it { should validate_presence_of(:result_at).on(:update) }
    it { should validate_presence_of(:media_used).on(:update) }
    it { should validate_presence_of(:test_result).on(:update) }
    it { should validate_inclusion_of(:media_used).in_array(media_options) }
    it { should validate_inclusion_of(:test_result).in_array(test_result_options) }
    it { should validate_inclusion_of(:result_status).in_array(result_status) }
  end
end
