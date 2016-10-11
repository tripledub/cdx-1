require 'spec_helper'

describe Institution do
  let(:user) { User.make }

  context 'validations' do
    it { should have_many(:sites) }
    it { should have_many(:devices) }
    it { should have_many(:device_models) }
    it { should have_many(:encounters) }
    it { should have_many(:patients) }
    it { should have_many(:samples) }
    it { should have_many(:test_results) }
    it { should have_many(:roles) }
    it { should have_many(:alerts) }
    it { should have_many(:feedback_messages) }
  end

  context 'feedback_messages' do
    it 'creates feedback messages for new institutions' do
      institution = Institution.make

      expect(institution.feedback_messages.count).to eq(10)
    end
  end

  describe "roles" do
    it "creates predefined roles for institution" do
      institution = nil
      expect { institution = Institution.make user_id: user.id }.to change(Role, :count).by(2)
      roles = Role.where(institution_id: institution.id).all
      roles.each do |role|
        expect(role.key).not_to eq(nil)
      end
    end

    it "renames predefined roles for institution on update" do
      institution = Institution.make user_id: user.id
      institution.name = "New Institution"
      institution.save!

      predefined = Policy.predefined_institution_roles(institution)
      existing = institution.roles.all

      existing.each do |existing_role|
        pre = predefined.find { |role| role.key == existing_role.key }
        expect(existing_role.name).to eq(pre.name)
      end
    end

    it "deletes all roles when destroyed" do
      institution = Institution.make user_id: user.id
      expect {
        institution.destroy
      }.to change(Role, :count).by(-2)
    end

    it "does not destroy if it has devices associated" do
      institution = Institution.make
      device = Device.make institution: institution
      expect(institution.destroy).to be_falsey
    end

    it "does not destroy if it has sites associated" do
      institution = Institution.make
      site = Site.make institution: institution
      expect(institution.destroy).to be_falsey
    end
  end
end
