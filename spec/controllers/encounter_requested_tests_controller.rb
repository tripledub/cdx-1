require 'spec_helper'
require 'policy_spec_helper'

describe EncounterRequestedTestsController  do
  let!(:institution) {Institution.make}
  let!(:user)        {institution.user}
  let!(:site)  { institution.sites.make }

  before(:each) {sign_in user}
  let(:default_params) { {context: institution.uuid} }

  context "update" do
    let!(:encounter) { Encounter.make institution: institution, site: site }
    let(:requested_test1)  {RequestedTest.make encounter: encounter}

    it "should update requestedTests status" do
      jsondata = 
          {
            "requestedTests" => {
              "id" => requested_test1.id,
              "status" => "deleted"
            }
          }
          
      post :update,  id: encounter.id, requestedTests: jsondata
      test = RequestedTest.find(requested_test1.id)   
      expect(RequestedTest.statuses[test.status]).to eq RequestedTest.statuses["deleted"]
    end
  end
end
