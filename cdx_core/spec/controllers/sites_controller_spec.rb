require 'spec_helper'
require 'policy_spec_helper'

describe SitesController do
  let!(:institution)   { Institution.make }
  let!(:user)          { institution.user }
  let!(:institution2)  { Institution.make }
  let!(:site2)         { institution2.sites.make }
  let(:default_params) { { context: institution.uuid } }

  before :each do
    sign_in user
  end

  context 'index' do
    let!(:site) { institution.sites.make }
    let!(:other_site) { Site.make }

    it 'should get accessible sites in index' do
      get :index

      expect(response).to be_success
      expect(assigns(:sites)).to contain_exactly(site)
      expect(assigns(:can_create)).to be_truthy
    end

    it 'should return a valid CSV when requested' do
      get :index, format: :csv
      csv = CSV.parse(response.body)
      expect(csv[0]).to eq(%w(Name Address City State Zipcode))
      expect(csv[1]).to eq([site.name, site.address, site.city, site.state, site.zip_code])
    end

    it 'should filter by institution if requested' do
      grant institution2.user, user, Institution, [READ_INSTITUTION]
      grant nil, user, "site?institution=#{institution2.id}", [READ_SITE]

      get :index, context: institution2.uuid

      expect(response).to be_success
      expect(assigns(:sites)).to contain_exactly(site2)
    end
  end

  context 'new' do
    let!(:site) { institution.sites.make }

    it 'should get new page' do
      get :new
      expect(response).to be_success
    end

    it 'should initialize no parent if context is institution' do
      get :new, context: institution.uuid
      expect(response).to be_success
      expect(assigns(:site).parent).to be_nil
    end

    it 'should initialize parent if context is site' do
      get :new, context: site.uuid
      expect(response).to be_success
      expect(assigns(:site).parent).to eq(site)
    end
  end

  context 'create' do
    it 'should create new site in context institution' do
      expect { post :create, site: Site.plan }.to change(institution.sites, :count).by(1)
      expect(response).to be_redirect
    end

    it 'should not create site in context institution despite params' do
      expect { post :create, site: Site.plan(institution: institution2) }.to change(institution.sites, :count).by(1)
      expect(response).to be_redirect
    end

    it 'should not create site in institution without permission to create site' do
      grant institution2.user, user, Institution, [READ_INSTITUTION]
      expect { post :create, context: institution2.uuid, site: Site.plan }.to change(institution.sites, :count).by(0)
      expect(response).to be_forbidden
    end

    it 'should create if no location geoid' do
      expect do
        site = Site.plan(institution: institution)
        site.delete :location_geoid
        post :create, site: site
      end.to change(institution.sites, :count).by(1)
      expect(response).to be_redirect
    end

    it 'should save a time_zone' do
      post :create, site: Site.plan(institution: institution2, name: 'New site', time_zone: 'Tokyo')
      new_site = Site.where(name: 'New site').first

      expect(new_site.time_zone).to eq('Tokyo')
    end
  end

  context 'edit' do
    let!(:site) { institution.sites.make }
    let!(:other_site) { Site.make }

    it 'should edit site' do
      get :edit, id: site.id

      expect(response).to be_success
    end

    it 'should not edit site if not allowed' do
      get :edit, id: site2.id
      expect(response).to be_forbidden
    end
  end

  context 'update' do
    let!(:site) { institution.sites.make }

    it 'should update site' do
      patch :update, id: site.id, site: {
        name: 'newname', address: '1 street', city: 'london', state: 'aa', zip_code: 'sw11', finance_approved: true
      }
      expect(site.reload.name).to eq('newname')
      expect(site.address).to eq('1 street')
      expect(site.city).to eq('london')
      expect(site.state).to eq('aa')
      expect(site.zip_code).to eq('sw11')
      expect(site.finance_approved).to be true
      expect(response).to be_redirect
    end

    it 'should not update parent site if user has no institution:createSite' do
      new_parent = institution.sites.make

      other_user = User.make
      grant user, other_user, institution, [READ_INSTITUTION]
      grant user, other_user, "site?institution=#{institution.id}", [READ_SITE]
      grant user, other_user, "site?institution=#{institution.id}", [UPDATE_SITE]

      sign_in other_user
      expect { patch :update, id: site.id, site: { name: 'newname', parent_id: new_parent.id } }.to change(Site, :count).by(0)

      expect(response).to redirect_to sites_path
    end

    context 'not changing parent site by user with institution:createSite policy' do
      let!(:parent) { institution.sites.make }
      let!(:site) { Site.make :child, parent: parent }
      let!(:device) { Device.make site: site }
      let!(:test) { TestResult.make device: device }

      before(:each) do
        patch :update, id: site.id, context: site.uuid, site:
          Site.plan(institution: institution).merge(parent_id: parent.id, name: 'new-name')

        site.reload
      end

      it 'should update existing site with the new name' do
        expect(site.parent_id).to eq(parent.id)
        expect(site.name).to eq('new-name')
      end

      it 'should keep devices and test' do
        expect(site.devices).to eq([device])
        expect(site.test_results).to eq([test])
      end
    end

    context 'change parent site by user with institution:createSite policy' do
      let!(:new_parent) { institution.sites.make }
      let(:new_site)    { Site.last }
      let!(:device)     { Device.make site: site }
      let!(:test)       { TestResult.make device: device }

      before(:each) do
        patch :update, id: site.id, context: site.uuid, site:
          Site.plan(institution: institution).merge(parent_id: new_parent.id, name: site.name)
        site.reload
      end

      it 'should redirect to sites_path' do
        expect(response).to redirect_to(sites_path(context: site.uuid))
      end

      it 'should update the parent id' do
        expect(site.parent_id).to eq(new_parent.id)
      end
    end
  end

  context 'destroy' do
    let!(:site) { institution.sites.make }

    it 'should destroy a site' do
      expect { delete :destroy, id: site.id }.to change(institution.sites, :count).by(-1)
      expect(response).to be_redirect
    end

    it 'should not destroy site for another institution' do
      expect { delete :destroy, id: site2.id }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'should not destroy site with associated devices' do
      site.devices.make
      expect(site.devices).not_to be_empty
      expect do
        expect { delete :destroy, id: site.id }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end.not_to change(institution.sites, :count)
    end

    it "should destroy a site after moving it's associated devices" do
      site3 = institution.sites.make
      site.devices.make
      expect(site.devices).not_to be_empty
      expect do
        expect { delete :destroy, id: site.id }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end.not_to change(institution.sites, :count)

      site.devices.each do |dev|
        dev.site = site3
        dev.save!
      end

      expect { delete :destroy, id: site.id }.to change(institution.sites, :count).by(-1)
    end
  end
end
