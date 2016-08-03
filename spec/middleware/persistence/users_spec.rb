require 'spec_helper'

RSpec.describe Persistence::Users do
  let(:institution)   { Institution.make }
  let(:user)          { institution.user }
  let(:site)          { institution.sites.make }
  let(:role)          { institution.roles.first }
  let!(:existant_user) { User.make email: 'existant@user.com'}
  let(:new_users)     { ['new@example.com', 'new@tester.com', 'existant@user.com'] }
  let(:message)       { 'Welcome to the test institution.'}

  before :each do
    user.grant_superadmin_policy
    existant_user.roles << role
    described_class.new(user).add_and_invite(new_users, message, role.id)
  end

  describe 'add_and_invite' do
    it 'adds new users' do
      expect(User.find_by_email('new@example.com')).to be
      expect(User.find_by_email('new@tester.com')).to be
    end

    it "sends mutiple invitations to new users" do
      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end

    it "adds role to new user" do
      new_user = User.find_by_email('new@example.com')
      expect(new_user.roles.count).to eq(1)
      expect(new_user.roles.first).to eq(role)
    end

    it "does not add duplicate roles to user if already present" do
      expect(existant_user.roles.count).to eq(1)
    end
  end
end
