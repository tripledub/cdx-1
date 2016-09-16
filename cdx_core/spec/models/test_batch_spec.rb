require 'spec_helper'

describe TestBatch do
  let(:status_options)  { ['new', 'samples_collected', 'in_progress', 'closed'] }

  context "validations" do
    it { should belong_to(:encounter) }
    it { should belong_to(:institution) }

    it { should have_many(:patient_results) }
    it { should validate_inclusion_of(:status).in_array(status_options) }
  end
end
