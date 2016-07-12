require 'spec_helper'

describe EncounterTestAuditLog do
  context "validations" do
    it { should validate_presence_of(:encounter_id) }
    it { should validate_presence_of(:requested_test_id) }
  end
end