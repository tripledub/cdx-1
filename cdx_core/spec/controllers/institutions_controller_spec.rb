require 'spec_helper'

describe InstitutionsController do
  let(:user)              { User.make }
  let!(:institution)      { user.institutions.make }
  let(:default_params)    { { context: institution.uuid } }
  let(:valid_institution) { {
    name: 'Updated institution',
    ftp_port:      22,
    ftp_passive:   true,
    ftp_hostname:  'ftp.myserver.com',
    ftp_directory: '/ftp',
    ftp_username:  'username',
    ftp_password:  '123456',
  } }

  before(:each) { sign_in user }

  context "index" do
    let!(:other_institution) { Institution.make }

    it "should list insitutions" do
      institution2 = user.institutions.make
      get :index

      expect(response).to be_success
      expect(assigns(:institutions)).to contain_exactly(institution, institution2)
    end

    it "should redirect to edit institution if there is only one institution" do
      get :index

      expect(response).to be_redirect
    end
  end

  context "create" do
    it "institution is created if name is provided" do
      post :create, {"institution" => {"name" => "foo"}}

      expect(Institution.count).to eq(2)
    end

    it "institutions without name are not created" do
      post :create, {"institution" => {"name" => ""}}

      expect(Institution.count).to eq(1)
    end

    it "sets the newly created institution in context (#796)" do
      post :create, {"institution" => {"name" => "foo"}}

      expect(user.reload.last_navigation_context).to eq(Institution.where(name: 'foo').first.uuid)
    end
  end

  context "new" do
    it "gets new page when there are no institutions" do
      get :new

      expect(response).to be_success
    end

    it "gets new page when there is one institution" do
      user.institutions.make
      get :new

      expect(response).to be_success
    end

    it "gets new page when there are many institutions" do
      2.times { user.institutions.make }
      get :new

      expect(response).to be_success
    end
  end

  context 'update' do
    before :each do
      put :update, id: institution.id, institution: valid_institution

      institution.reload
    end

    it 'should update the name' do
      expect(institution.name).to eq('Updated institution')
    end

    it 'should update the ftp username' do
      expect(institution.ftp_username).to eq('username')
    end

    it 'should update the ftp hostname' do
      expect(institution.ftp_hostname).to eq('ftp.myserver.com')
    end

    it 'should update the ftp directory' do
      expect(institution.ftp_directory).to eq('/ftp')
    end

    it 'should update the ftp passive method' do
      expect(institution.ftp_passive).to be true
    end

    it 'should update the ftp port' do
      expect(institution.ftp_port).to eq(22)
    end

    it 'should update the ftp password' do
      expect(institution.ftp_password).to eq('123456')
    end
  end
end
