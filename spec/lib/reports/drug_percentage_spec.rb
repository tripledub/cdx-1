require 'spec_helper'

describe Reports::DrugPercentage do
  let(:user)               { User.make }
  let!(:institution)       { user.institutions.make }
  let(:patient)            { Patient.make institution: institution }
  let(:encounter)          { Encounter.make institution: institution , user: user, patient: patient }
  let(:requested_test)     { RequestedTest.make encounter: encounter }
  let(:navigation_context) { NavigationContext.new(user, institution.uuid) }
  let!(:results)           {
    XpertResult.make requested_test: requested_test, tuberculosis: 'detected', rifampicin: 'detected', created_at: 2.years.ago
    XpertResult.make requested_test: requested_test, tuberculosis: 'not_detected', rifampicin: 'detected'
    XpertResult.make requested_test: requested_test, tuberculosis: 'detected', rifampicin: 'not_detected'
    XpertResult.make requested_test: requested_test, tuberculosis: 'detected', rifampicin: 'detected'
    XpertResult.make requested_test: requested_test, tuberculosis: 'invalid', rifampicin: 'indeterminate', created_at: 3.years.ago
    XpertResult.make requested_test: requested_test, tuberculosis: 'not_detected', rifampicin: 'detected', created_at: 14.months.ago
    XpertResult.make requested_test: requested_test, tuberculosis: 'not_detected', rifampicin: 'indeterminate'
  }

  xdescribe 'generate_chart' do
    context 'no date filter' do
      it 'should return the total of XpertResult with tuberculosis status detected' do
        expect(Reports::DrugPercentage.new(user, navigation_context,{}).generate_chart[:columns].first[:y]).to eq(2)
      end

      it 'should return the total of XpertResult with with rifampicin status detected' do
        expect(Reports::DrugPercentage.new(user, navigation_context,{}).generate_chart[:columns][1][:y]).to eq(2)
      end

      it 'should return the total of XpertResult with with rifampicin and tuberculosis status detected' do
        expect(Reports::DrugPercentage.new(user, navigation_context,{}).generate_chart[:columns].last[:y]).to eq(1)
      end
    end

    context 'with date filter' do
      let(:params) { { 'date_range' => { 'start_time' => { 'gte' => 3.years.ago.strftime("%Y-%m-%d"), 'lte' => Date.today.strftime("%Y-%m-%d") } } } }

      it 'should return the total of XpertResult with tuberculosis status detected' do
        expect(Reports::DrugPercentage.new(user, navigation_context, params).generate_chart[:columns].first[:y]).to eq(3)
      end

      it 'should return the total of XpertResult with with rifampicin status detected' do
        expect(Reports::DrugPercentage.new(user, navigation_context, params).generate_chart[:columns][1][:y]).to eq(4)
      end

      it 'should return the total of XpertResult with with rifampicin and tuberculosis status detected' do
        expect(Reports::DrugPercentage.new(user, navigation_context, params).generate_chart[:columns].last[:y]).to eq(2)
      end
    end
  end
end
