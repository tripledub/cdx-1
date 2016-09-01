require 'spec_helper'
require 'policy_spec_helper'

describe "performance", elasticsearch: true do
  let(:institution) { Institution.make }
  let(:user) { institution.user }
  let(:site) { institution.sites.make }
  let!(:device_spec_helper) { DeviceSpecHelper.new 'genexpert' }
  let!(:device) { device_spec_helper.make site: site }

  before(:each) {
    device_spec_helper.import_sample_json device, 'genexpert_sample.json'
    device_spec_helper.import_sample_json device, 'genexpert_sample_qc.json'
    sign_in(user)
  }

  it "should have 2 test results" do
    expect(device.test_results.count).to eq(2)
  end
end
