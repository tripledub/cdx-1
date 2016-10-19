require 'spec_helper'

describe DstLpaResult do
  let(:dst_lpa_options) { %w(resistant susceptible contaminated not_done) }
  let(:media_options) { %w(solid liquid) }
  let(:method_options) { %w(direct indirect) }
  let(:result_status) { %w(new sample_collected allocated pending_approval rejected completed) }

  describe 'validations' do
    it { should validate_presence_of(:sample_collected_at).on(:update) }
    it { should validate_presence_of(:examined_by).on(:update) }
    it { should validate_presence_of(:result_at).on(:update) }
    it { should validate_presence_of(:media_used).on(:update) }
    it { should validate_presence_of(:results_h).on(:update) }
    it { should validate_presence_of(:results_r).on(:update) }
    it { should validate_presence_of(:results_e).on(:update) }
    it { should validate_presence_of(:results_s).on(:update) }
    it { should validate_presence_of(:results_amk).on(:update) }
    it { should validate_presence_of(:results_km).on(:update) }
    it { should validate_presence_of(:results_cm).on(:update) }
    it { should validate_presence_of(:results_fq).on(:update) }
    it { should validate_inclusion_of(:results_h).in_array(dst_lpa_options) }
    it { should validate_inclusion_of(:results_r).in_array(dst_lpa_options) }
    it { should validate_inclusion_of(:results_e).in_array(dst_lpa_options) }
    it { should validate_inclusion_of(:results_s).in_array(dst_lpa_options) }
    it { should validate_inclusion_of(:results_amk).in_array(dst_lpa_options) }
    it { should validate_inclusion_of(:results_km).in_array(dst_lpa_options) }
    it { should validate_inclusion_of(:results_cm).in_array(dst_lpa_options) }
    it { should validate_inclusion_of(:results_fq).in_array(dst_lpa_options) }
    it { should validate_inclusion_of(:media_used).in_array(media_options) }
    it { should validate_inclusion_of(:method_used).in_array(method_options) }
    it { should validate_inclusion_of(:result_status).in_array(result_status) }
  end
end
