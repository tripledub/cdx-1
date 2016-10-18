require 'spec_helper'

describe IntegrationLogsController, type: :controller do
  let!(:institution) {Institution.make}
  let!(:user)        {institution.user}
  before(:each) {sign_in user}
  let(:default_params) { {context: institution.uuid} }
  
  describe "GET index" do
    it "should load index as HTML" do
      get :index
      expect(response).to be_success
    end
    
    it "should sort on updated at" do
      log_1 = IntegrationLog.make patient_name: "name 1", updated_at: Time.now.yesterday
      log_2 = IntegrationLog.make patient_name: "name 2", updated_at: Time.now
      
      get :index
      expect(response).to be_success
      expect(assigns(:integration_logs).to_a).to eq([log_1, log_2])
    end
  end
  
  describe "GET retry" do
    it 'should response as success' do
      get :retry, id: 1
      expect(response).to be_success
    end
    
    it 'should response error for finished case' do
      log = IntegrationLog.make patient_name: "name 1", status: "Finished"
      @expected = { 
        :success    => false
      }.to_json
      
      get :retry, id: log.id
      expect(response.body).to eq @expected
    end
  end
end