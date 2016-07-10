require 'spec_helper'

describe Reports::DrtbPercentage do
  let(:user)               { User.make }
  let!(:institution)       { user.institutions.make }
  let(:patient)            { Patient.make institution: institution }
  let(:encounter)          { Encounter.make institution: institution , user: user, patient: patient }
  let(:requested_test)     { RequestedTest.make encounter: encounter }

  describe 'generate_chart' do
    let(:navigation_context) { NavigationContext.new(user, institution.uuid) }

    before :each do
      XpertResult.make requested_test: requested_test, tuberculosis: 'detected', created_at: 2.years.ago
      XpertResult.make requested_test: requested_test, tuberculosis: 'not_detected'
      XpertResult.make requested_test: requested_test, tuberculosis: 'detected'
      XpertResult.make requested_test: requested_test, tuberculosis: 'detected'
      XpertResult.make requested_test: requested_test, tuberculosis: 'invalid', created_at: 3.years.ago
    end

    context 'no date filter' do
      it 'should return the total of XpertResult with status not detected' do
        expect(Reports::DrtbPercentage.new(user, navigation_context,{}).generate_chart[:columns].first[:y]).to eq(1)
      end

      it 'should return the total of XpertResult with status detected' do
        expect(Reports::DrtbPercentage.new(user, navigation_context,{}).generate_chart[:columns].last[:y]).to eq(2)
      end
    end

    context 'with date filter' do
      let(:params) { { 'date_range' => { 'start_time' => { 'gte' => 3.years.ago.strftime("%Y-%m-%d"), 'lte' => Date.today.strftime("%Y-%m-%d") } } } }

      it 'should return the total of XpertResult with status not detected' do
        expect(Reports::DrtbPercentage.new(user, navigation_context, params).generate_chart[:columns].first[:y]).to eq(2)
      end

      it 'should return the total of XpertResult with status detected' do
        expect(Reports::DrtbPercentage.new(user, navigation_context, params).generate_chart[:columns].last[:y]).to eq(3)
      end
    end
  end
end
