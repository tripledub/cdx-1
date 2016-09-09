require 'spec_helper'

describe "device model" do
  let(:user)    { Institution.make.user }
  before(:each) { sign_in(user) }

  it "can create model and access to it's details", testrail: 424 do
    goto_page NewDeviceModelPage do |page|
      page.name.set "MyModel"
      page.support_url.set "example.org/support"
      page.manifest.attach "db/seeds/manifests/genoscan_manifest.json"
      page.submit
    end

    expect_page DeviceModelsPage do |page|
      page.table.items.first.tap do |item|
        expect(item).to have_content("MyModel")
        item.click
      end
    end

    expect_page DeviceModelPage do |page|
      expect(page.name.value).to eq("MyModel")
    end
  end
end
