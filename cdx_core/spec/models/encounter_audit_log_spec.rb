require 'spec_helper'

describe EncounterAuditLog do
  context "validations" do
    it { should validate_presence_of(:encounter_id) }
  end
end
