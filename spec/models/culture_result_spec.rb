require 'spec_helper'

describe CultureResult do
  let(:media_options)  { ['solid', 'liquid'] }

  context "validations" do
    it { should belong_to(:requested_test) }
    it { should validate_presence_of(:sample_collected_on) }
    it { should validate_presence_of(:examined_by) }
    it { should validate_presence_of(:result_on) }
    it { should validate_presence_of(:media_used) }
    it { should validate_presence_of(:serial_number) }
    it { should validate_inclusion_of(:media_used).in_array(media_options) }
  end
  
  context "find associated patient results" do
      let(:encounter) { Encounter.make }
      let(:requested_test) { RequestedTest.make encounter: encounter}

      it "should find associated patient tests" do
        result1 = CultureResult.new encounter_id: encounter.id, requested_test_id: requested_test.id
        result1.save(validate: false)
        expect(PatientResult.find_associated_tests_to_results(encounter).length).to eq(1)  
      end
    end
    
end
