require 'spec_helper'

describe FeedbackMessage do
  describe 'associations' do
    it { should belong_to :institution }
    it { should have_many :patient_results }
    it { should have_many :encounters }
    it { should have_many :custom_translations }
  end
end
