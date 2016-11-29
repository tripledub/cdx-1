require 'spec_helper'

RSpec.describe Reports::DailyOrderStatus do
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
  let!(:microscopy_result)  { MicroscopyResult.make encounter: encounter, result_at: 1.day.ago }
  let!(:xpert_result)       { XpertResult.make encounter: encounter, tuberculosis: 'indeterminate', result_at: 3.days.ago }
  let!(:xpert_result2)      { XpertResult.make encounter: encounter, tuberculosis: 'no_result', result_at: 1.day.ago }
  let!(:dst_result)         { DstLpaResult.make encounter: encounter, results_h: 'contaminated', result_at: 2.days.ago }
  let(:navigation_context)  { NavigationContext.new(current_user, institution.uuid) }
  let(:options)             { {} }
  let!(:test_results) do
    TestResult.make(
      result_status: 'success',
      device_messages: [DeviceMessage.make(device: user_device)]
    )

    TestResult.make(
      result_status: 'error',
      device_messages: [DeviceMessage.make(device: user_device)]
    )

    TestResult.make(
      result_status: 'error',
      device_messages: [DeviceMessage.make(device: user_device)]
    )

    TestResult.make(
      result_status: 'success',
      device_messages: [DeviceMessage.make(device: user_device)]
    )
  end

  before do
    microscopy_result.update_attribute(:result_status, 'sample_collected')
    xpert_result.update_attribute(:result_status, 'allocated')
    xpert_result2.update_attribute(:result_status, 'allocated')
    dst_result.update_attribute(:result_status, 'completed')
  end

  describe '.sort' do
    subject { described_class.new(navigation_context, options).generate_chart }

    it 'returns the number of successful tests' do
      expect(subject[:columns].first[:y]).to eq(2)
      expect(subject[:columns].first[:legendText]).to eq('Allocated')
    end

    it 'returns the number of failing tests' do
      expect(subject[:columns].last[:y]).to eq(2)
      expect(subject[:columns].last[:legendText]).to eq('Success')
    end
  end
end
