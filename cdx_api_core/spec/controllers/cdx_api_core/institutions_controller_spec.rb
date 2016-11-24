require 'spec_helper'

describe CdxApiCore::InstitutionsController do
  let!(:user) { User.make }
  let!(:institution) { Institution.make user: user, name: 'Acme Institution' }

  context "with signed in user" do
    before(:each) { sign_in user }

    context "Institutions" do
      it "should list the institution" do
        result = get :index, format: 'json'

        expect(Oj.load(result.body)).to eq({'total_count' => 1, 'institutions' => [
          {'uuid' => institution.uuid, 'name' => institution.name}
        ]})
      end


      it "should list the institutions for given user" do
        other_institution = Institution.make user: user, name: 'Other Institution'
        Institution.make user: User.make
        result = get :index, format: 'json'

        all_institutions = [
          {'uuid' => institution.uuid, 'name' => institution.name},
          {'uuid' => other_institution.uuid, 'name' => other_institution.name}
        ]
        new_sorted_institutions = all_institutions.sort_by { |f| f['name'] }

        expect(Oj.load(result.body)).to eq({'total_count' => 2, 'institutions' =>
          new_sorted_institutions
        })
      end
    end
  end

  context "with api token" do
    let!(:token) { user.create_api_token }

    it "should list the institution" do
      result = get :index, access_token: token.token, format: 'json'

      expect(Oj.load(result.body)).to eq({'total_count' => 1, 'institutions' => [
        {'uuid' => institution.uuid, 'name' => institution.name}
      ]})
    end
  end
end
