require 'spec_helper'

RSpec.describe EncountersHelper, type: :helper do
  let(:current_user) { User.make }
  let(:institution) { Institution.make user: current_user }
  let!(:site_one) do
    Site.make institution: institution, user: current_user, name: 'First'
  end
  let!(:site_two) do
    Site.make institution: institution, user: current_user, name: 'Last'
  end

  describe '.encounter_context' do
    context 'when navigation context is a site' do
      let(:navigation_context) do
        NavigationContext.new(current_user, site_two.uuid)
      end
      it 'uses selected site' do
        context = helper.encounter_context(navigation_context)
        expect(context[:site][:name]).to eq(site_two.name)
      end
    end

    context 'when navigation context is an institution' do
      let(:navigation_context) do
        NavigationContext.new(current_user, institution.uuid)
      end
      it 'defaults to first site in institution' do
        context = helper.encounter_context(navigation_context)
        expect(context[:site][:name]).to eq(site_one.name)
      end
    end
  end
end
