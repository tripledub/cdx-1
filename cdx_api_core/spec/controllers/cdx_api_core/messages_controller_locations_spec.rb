require 'spec_helper'

xdescribe CdxApiCore::MessagesController, validate_manifest: false do
  let(:user) {User.make}
  let(:institution) {Institution.make user_id: user.id}
  let(:device) {Device.make institution_id: institution.id}
  let(:data) {Oj.dump test: {assays: [result: :positive]}}

  before(:each) {sign_in user}

  context "Locations" do
    let(:parent_location) {Location.make}
    let(:leaf_location1) {Location.make parent: parent_location}
    let(:leaf_location2) {Location.make parent: parent_location}
    let(:upper_leaf_location) {Location.make}

    let(:site1) {Site.make institution: institution, location_geoid: leaf_location1.id}

    it "should store the location id when the device is registered in only one site" do
      device.site = site1
      device.save!
      post :create, data, device_id: device.uuid, authentication_token: device.plain_secret_key
    end

    xit "should not index if no location/site was found but must keep the DeviceMessage" do
      device.site = nil
      device.save!
      expect {
        post :create, data, device_id: device.uuid, authentication_token: device.plain_secret_key
      }.to change{ DeviceMessage.count }.by(1)

      expect(DeviceMessage.last.index_failed).to be_truthy
    end
  end
end
