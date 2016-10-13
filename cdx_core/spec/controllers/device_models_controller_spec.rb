require 'spec_helper'
require 'policy_spec_helper'

describe DeviceModelsController do

  let!(:user)          { User.make }
  let!(:institution)   { user.institutions.make  }
  let!(:device_model)  { institution.device_models.make(:unpublished) }
  let!(:institution1)  { user.institutions.make }
  let!(:device_model1) { institution1.device_models.make(:unpublished) }

  let!(:user2)         { User.make }
  let!(:institution2)  { user2.institutions.make }
  let!(:device_model2) { institution2.device_models.make(:unpublished) }
  let!(:device_model3) { institution2.device_models.make(:unpublished) }
  let(:default_params) { { context: institution.uuid } }

  let(:manifest_attributes) do
    {"definition" => %{{
      "metadata": {
        "version" : "1.0.0",
        "api_version" : "#{Manifest::CURRENT_VERSION}",
        "conditions": ["mtb"],
        "source" : { "type" : "json" }
      },
      "field_mapping": {
        "test.assay_name" : {"lookup" : "Test.assay_name"},
        "test.type" : {
          "case" : [
            {"lookup" : "Test.test_type"},
            [
              {"when" : "*QC*", "then" : "qc"},
              {"when" : "*Specimen*", "then" : "specimen"}
            ]
          ]
        }
      }
    }} }
  end

  before :each do
    sign_in user
  end

  context "index" do
    it "should list all device models of selected institution for a manufacturer admin" do
      get :index
      expect(assigns(:device_models)).to match_array([device_model])
      expect(response).to be_success
    end

  end


  context "new" do
    it "should render new page" do
      get :new
      expect(response).to be_success
      expect(assigns(:device_model)).to_not be_nil
    end

    it "should assign institution if there is only one" do
      get :new
      expect(response).to be_success
      expect(assigns(:device_model).institution).to eq(institution)
    end

  end


  context "create" do

    it "should create a device model" do
      expect {
        post :create, device_model: { name: "GX4001", manifest_attributes: manifest_attributes, supports_activation: true, support_url: "http://example.org/gx4001" }
      }.to change(DeviceModel, :count).by(1)
      new_device_model = DeviceModel.last
      expect(new_device_model).to_not be_published
      expect(new_device_model.institution).to eq(institution)
      expect(new_device_model.supports_activation).to be_truthy
      expect(new_device_model.support_url).to eq("http://example.org/gx4001")
      expect(response).to be_redirect
    end

    it "should not create if JSON is not valid" do
      json = {"definition" => %{ { , , } } }
      expect {
        post :create, device_model: { name: "GX4001", manifest_attributes: json }
      }.to change(DeviceModel, :count).by(0)
    end

    it "should not allow to create in unauthorised institution" do
      grant user2, user, institution2, READ_INSTITUTION
      expect {
        post :create, context: institution2.uuid, device_model: { name: "GX4001", manifest_attributes: manifest_attributes }
      }.to change(DeviceModel, :count).by(0)
      expect(response).to be_forbidden
    end

    it "should not create in other institution even if authorised" do
      grant user2, user, institution2, READ_INSTITUTION
      grant user2, user, institution2, REGISTER_INSTITUTION_DEVICE_MODEL
      post :create, context: institution2.uuid, device_model: { name: "GX4001", manifest_attributes: manifest_attributes }
      expect(response).to be_forbidden
    end

    it "should publish on creation" do
      expect {
        post :create, publish: "1", device_model: { name: "GX4001", manifest_attributes: manifest_attributes }
      }.to change(DeviceModel, :count).by(1)
      expect(DeviceModel.last).to be_published
      expect(response).to be_redirect
    end

    it "should not persist published mark if validation fails" do
      json = {"definition" => %{ { , , } } }
      post :create, publish: "1", device_model: { name: "GX4001", manifest_attributes: json }
      expect(assigns(:device_model)).to_not be_published
    end

  end


  context "edit" do
    it "should render edit page" do
      get :edit, id: device_model.id
      expect(response).to be_success
      expect(assigns(:device_model)).to eq(device_model)
    end

    it "should not render edit page if other institution" do
      grant user2, user, device_model2, UPDATE_DEVICE_MODEL
      get :edit, id: device_model2.id
      expect(response).to be_forbidden
    end

    it "should not render edit page if unauthorised" do
      get :edit, id: device_model2.id
      expect(response).to be_forbidden
    end
  end

  context "update" do
    let(:published_device_model)  { institution.device_models.make }
    let(:published_device_model2) { institution2.device_models.make }

    let(:site)  { institution.sites.make }
    let(:site2) { institution2.sites.make }

    it "should update a device model" do
      patch :update, id: device_model.id, device_model: { name: "NEWNAME", supports_activation: true, manifest_attributes: manifest_attributes, support_url: "http://example.org/new" }
      expect(device_model.reload.name).to eq("NEWNAME")
      expect(device_model.supports_activation).to be_truthy
      expect(device_model.support_url).to eq("http://example.org/new")
      expect(device_model.reload).to_not be_published
      expect(response).to be_redirect
    end

    it "should publish a device model" do
      patch :update, id: device_model.id, publish: "1", device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(device_model.reload.name).to eq("NEWNAME")
      expect(device_model.reload).to be_published
      expect(response).to be_redirect
    end

    it "should not update a device model if unauthorised" do
      patch :update, id: device_model2.id, device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(response).to be_forbidden
    end

    it "should not update a device model from another institution even if authorised" do
      grant user2, user, device_model2, UPDATE_DEVICE_MODEL
      patch :update, id: device_model2.id, device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(response).to be_forbidden
    end

    it "should not publish a device model from another institution if unauthorised" do
      grant user2, user, device_model2, [UPDATE_DEVICE_MODEL]
      patch :update, id: device_model2.id, publish: "1", device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(device_model2.reload).to_not be_published
      expect(response).to be_forbidden
    end

    it "should not publish a device model from another institution even if authorised" do
      grant user2, user, device_model2, [UPDATE_DEVICE_MODEL, PUBLISH_DEVICE_MODEL]
      patch :update, id: device_model2.id, publish: "1", device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(response).to be_forbidden
    end

    it "should not allow to change institution" do
      grant user2, user, [Institution, DeviceModel], "*"
      patch :update, id: device_model.id, device_model: { name: "NEWNAME", institution_id: institution2.id, manifest_attributes: manifest_attributes }
      expect(device_model.reload.institution_id).to eq(institution.id)
      expect(response).to_not be_success
    end

    it "should unpublish a device model" do
      patch :update, id: published_device_model.id, unpublish: "1", device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(published_device_model.reload.name).to eq("NEWNAME")
      expect(published_device_model.reload).to_not be_published
      expect(response).to be_redirect
    end

    it "should not unpublish a device model for another institution even if authorised" do
      grant nil, user, published_device_model2, [UPDATE_DEVICE_MODEL, PUBLISH_DEVICE_MODEL]
      patch :update, id: published_device_model2.id, unpublish: "1", device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(response).to be_forbidden
    end

    it "should not unpublish a device model if unauthorised" do
      grant nil, user, published_device_model2, [UPDATE_DEVICE_MODEL]
      patch :update, id: published_device_model2.id, unpublish: "1", device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(published_device_model2.reload).to be_published
    end

    it "should unpublish a device model if it has devices in the same institution" do
      published_device_model.devices.make(site: site)
      patch :update, id: published_device_model.id, unpublish: "1", device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(published_device_model.reload).to_not be_published
    end

    it "should not unpublish a device model if it has devices outside the institution" do
      published_device_model.devices.make(site: site2)
      patch :update, id: published_device_model.id, unpublish: "1", device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(published_device_model.reload.name).to eq("NEWNAME")
      expect(published_device_model.reload).to be_published
      expect(response).to be_redirect
    end

    it "should update a published device model" do
      patch :update, id: published_device_model.id, device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(published_device_model.reload.name).to eq("NEWNAME")
      expect(published_device_model.reload).to be_published
      expect(response).to be_redirect
    end

    it "should not update a published device model if unauthorised" do
      grant user2, user, DeviceModel, UPDATE_DEVICE_MODEL
      patch :update, id: published_device_model2.id, device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(published_device_model2.reload.name).to_not eq("NEWNAME")
      expect(published_device_model2.reload).to be_published
    end

    it "should not update a published device model from another institution even if authorised" do
      grant user2, user, DeviceModel, [UPDATE_DEVICE_MODEL, PUBLISH_DEVICE_MODEL]
      patch :update, id: published_device_model2.id, device_model: { name: "NEWNAME", manifest_attributes: manifest_attributes }
      expect(response).to be_forbidden
    end

  end


  context "publish" do

    let(:published_device_model)  { institution.device_models.make }
    let(:published_device_model2) { institution2.device_models.make }

    let(:site)  { institution.sites.make }
    let(:site2) { institution2.sites.make }

    it "should publish a device model" do
      put :publish, id: device_model.id, publish: "1"
      expect(device_model.reload).to be_published
      expect(response).to be_redirect
    end

    it "should not publish a device model from another institution if unauthorised" do
      grant user2, user, device_model2, [UPDATE_DEVICE_MODEL]
      put :publish, id: device_model2.id, publish: "1"
      expect(device_model2.reload).to_not be_published
    end

    it "should not publish a device model from another institution even if authorised" do
      grant user2, user, device_model2, [UPDATE_DEVICE_MODEL, PUBLISH_DEVICE_MODEL]
      put :publish, id: device_model2.id, publish: "1"
      expect(response).to be_forbidden
    end

    it "should unpublish a device model" do
      put :publish, id: published_device_model.id, unpublish: "1"
      expect(published_device_model.reload).to_not be_published
      expect(response).to be_redirect
    end

    it "should not unpublish a device model even if authorised" do
      grant nil, user, published_device_model2, [UPDATE_DEVICE_MODEL, PUBLISH_DEVICE_MODEL]
      put :publish, id: published_device_model2.id, unpublish: "1"
      expect(response).to be_forbidden
    end

    it "should not unpublish a device model if unauthorised" do
      grant nil, user, published_device_model2, [UPDATE_DEVICE_MODEL]
      put :publish, id: published_device_model2.id, unpublish: "1"
      expect(published_device_model2.reload).to be_published
    end

    it "should unpublish a device model if it has devices in the same institution" do
      published_device_model.devices.make(site: site)
      put :publish, id: published_device_model.id, unpublish: "1"
      expect(published_device_model.reload).to_not be_published
    end

    it "should not unpublish a device model if it has devices outside the institution" do
      published_device_model.devices.make(site: site2)
      put :publish, id: published_device_model.id, unpublish: "1"
      expect(published_device_model.reload).to be_published
    end

  end


  context "destroy" do

    let(:published_device_model)  { institution.device_models.make }

    it "should delete a device model" do
      expect {
        delete :destroy, id: device_model.id
      }.to change(DeviceModel, :count).by(-1)
    end

    it "should not delete a device model if unauthorised" do
      expect {
        delete :destroy, id: device_model2.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not delete a device model if published" do
      published_device_model
      expect {
        delete :destroy, id: published_device_model.id
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(published_device_model.reload.id).to be_not_nil
    end

    it "should not delete a device model from another institution even if authorised" do
      grant user2, user, device_model2, DELETE_DEVICE_MODEL
      expect {
        delete :destroy, id: device_model2.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

  end

end
