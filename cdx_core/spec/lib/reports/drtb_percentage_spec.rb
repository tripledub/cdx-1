require 'spec_helper'

describe Reports::DrtbPercentage do
  let(:user)               { User.make }
  let!(:institution)       { user.institutions.make }
  let(:patient)            { Patient.make institution: institution }
  let(:encounter)          { Encounter.make institution: institution , user: user, patient: patient }
  let(:navigation_context) { NavigationContext.new(user, institution.uuid) }
  let!(:results) {
    XpertResult.make encounter: encounter, tuberculosis: 'detected',     rifampicin: 'detected', created_at: 2.years.ago
    XpertResult.make encounter: encounter, tuberculosis: 'not_detected', rifampicin: 'detected'
    XpertResult.make encounter: encounter, tuberculosis: 'detected',     rifampicin: 'not_detected'
    XpertResult.make encounter: encounter, tuberculosis: 'detected',     rifampicin: 'indeterminate'
    XpertResult.make encounter: encounter, tuberculosis: 'invalid',      rifampicin: 'indeterminate', created_at: 3.years.ago
  }

  xdescribe 'generate_chart' do
    context 'no date filter' do
      it 'should return the total of XpertResult with status not detected' do
        expect(Reports::DrtbPercentage.new(user, navigation_context,{}).generate_chart[:columns].first[:y]).to eq(0)
      end

      it 'should return the total of XpertResult with tuberculosis or rifampicin status detected' do
        expect(Reports::DrtbPercentage.new(user, navigation_context,{}).generate_chart[:columns].last[:y]).to eq(3)
      end
    end

    context 'with date filter' do
      let(:params) { { 'date_range' => { 'start_time' => { 'gte' => 3.years.ago.strftime("%Y-%m-%d"), 'lte' => Date.today.strftime("%Y-%m-%d") } } } }

      it 'should return the total of XpertResult with status not detected' do
        expect(Reports::DrtbPercentage.new(user, navigation_context, params).generate_chart[:columns].first[:y]).to eq(1)
      end

      it 'should return the total of XpertResult with tuberculosis or rifampicin status detected' do
        expect(Reports::DrtbPercentage.new(user, navigation_context, params).generate_chart[:columns].last[:y]).to eq(4)
      end
    end
  end
end
