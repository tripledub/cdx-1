require 'spec_helper'
require 'sidekiq/testing'

RSpec.describe Persistence::Users do
  let(:institution)    { Institution.make }
  let(:user)           { institution.user }
  let(:site)           { institution.sites.make }
  let(:role)           { institution.roles.first }
  let!(:existant_user) { User.make email: 'existant@user.com'}
  let(:new_users)      { ['new@example.com', 'new@tester.com', 'existant@user.com'] }
  let(:message)        { 'Welcome to the test institution.'}

  before :each do
    user.last_navigation_context = institution.uuid
    user.save!
    user.grant_superadmin_policy
    existant_user.roles << role
    Sidekiq::Worker.clear_all
    described_class.new(user).add_and_invite(new_users, message, role)
  end

  describe 'add_and_invite' do
    it 'adds new users' do
      expect(User.find_by_email('new@example.com')).to be
      expect(User.find_by_email('new@tester.com')).to be
    end

    it 'sends mutiple invitations to new users' do
      Sidekiq::Testing.fake!
      expect(Sidekiq::Extensions::DelayedMailer.jobs.size).to eq(2)
    end

    it "adds role to new user" do
      new_user = User.find_by_email('new@example.com')

      expect(new_user.roles.count).to eq(2)
      expect(new_user.roles).to include(role)
    end

    it "adds default institution read permision to user" do
      new_user = User.find_by_email('new@example.com')
      role     = Role.where(name: "Institution #{institution.name} Reader").first

      expect(new_user.roles).to include(role)
    end
  end

  context 'when context is a site not an institution' do
    before :each do
      user.last_navigation_context = site.uuid
      user.save!
      user.grant_superadmin_policy
      existant_user.roles << role
      described_class.new(user).add_and_invite(new_users, message, role)
    end

    it "adds default institution read permision to user when context is a site" do
      new_user = User.find_by_email('new@example.com')
      role     = Role.where(name: "Institution #{institution.name} Reader").first

      expect(new_user.roles).to include(role)
    end
  end
end
