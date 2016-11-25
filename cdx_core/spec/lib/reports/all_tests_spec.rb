require 'spec_helper'

RSpec.describe Reports::AllTests do
  let(:current_user)        { User.make }
  let(:institution)         { Institution.make(user_id: current_user.id) }
  let(:site)                { Site.make(institution: institution) }
  let(:current_user_two)    { User.make }
  let(:institution_two)     { Institution.make(user_id: current_user_two.id) }
  let(:site_two)            { Site.make(institution: institution_two) }
  let(:user_device)         { Device.make institution_id: institution.id, site: site }
  let(:user_device_two)     { Device.make institution_id: institution_two.id, site: site_two }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution, user: current_user, patient: patient }
  let!(:microscopy_result)  { MicroscopyResult.make encounter: encounter }
  let!(:culture_result)     { CultureResult.make encounter: encounter }
  let(:nav_context)         { NavigationContext.new(current_user, institution.uuid) }
  let(:options)             { {} }

  before do
    TestResult.make(
      result_status: 'success',
      device_messages: [DeviceMessage.make(device: user_device)]
    )

    TestResult.make(
      result_at: Time.now - 1.day,
      result_status: 'error',
      device_messages: [DeviceMessage.make(device: user_device)]
    )

    TestResult.make(
      result_at: Time.now - 1.month,
      result_status: 'success',
      device_messages: [DeviceMessage.make(device: user_device)]
    )

    TestResult.make(
      result_at: Time.now - 1.month,
      result_status: 'error',
      device_messages: [DeviceMessage.make(device: user_device)]
    )

    TestResult.make(
      result_status: 'success',
      device_messages: [DeviceMessage.make(device: user_device_two)]
    )
  end

  describe 'process results' do
    context 'no filters' do
      subject { Reports::AllTests.new(nav_context).generate_chart }

      it 'returns an array of columns' do
        expect(subject[:columns].size).to eq(2)
      end

      it 'counts all results' do
        expect(subject[:columns].first[:dataPoints].size).to eq(2)
      end

      it 'counts error results' do
        expect(subject[:columns].last[:dataPoints].first[:y]).to eq(1)
      end

      context 'statuses' do
        it 'includes :error' do
          expect(subject[:columns].last[:name]).to eq('Errors')
        end

        it 'includes all tests' do
          expect(subject[:columns].first[:name]).to eq('Tests')
        end
      end
    end

    context 'when date range is a year' do
      before do
        options['since'] = (Date.today - 1.year).iso8601
      end

      subject { Reports::AllTests.new(nav_context, options).generate_chart }

      it 'can sort results by month' do
        expect(subject[:columns].first[:dataPoints].first[:y]).to eq(2)
      end
    end
  end
end
