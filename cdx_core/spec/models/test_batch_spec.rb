require 'spec_helper'

describe TestBatch do
  context "validations" do
    it { should belong_to(:encounter) }
    it { should belong_to(:institution) }

    it { should have_many(:patient_results) }
  end
end
