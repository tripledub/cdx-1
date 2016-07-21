require 'spec_helper'

RSpec.describe Reports::AverageTechnicianTests, elasticsearch: true do
  let(:current_user)        { User.make }
  let(:site_user)           { "#{current_user.first_name} #{current_user.last_name}" }
  let(:site_user2)          { "B. smith" }
  let(:institution)         { Institution.make(user_id: current_user.id) }
  let(:site)                { Site.make(institution: institution) }
  let(:site2)               { Site.make(institution: institution) }
  let(:current_user_two)    { User.make }
  let(:institution_two)     { Institution.make(user_id: current_user_two.id) }
  let(:site_two)            { Site.make(institution: institution_two) }
  let(:user_device)         { Device.make institution_id: institution.id, site: site }
  let(:user_device_two)     { Device.make institution_id: institution_two.id, site: site_two }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: current_user, patient: patient, site: site }
  let(:encounter2)          { Encounter.make institution: institution , user: current_user, patient: patient, site: site2 }
  let(:requested_test)      { RequestedTest.make encounter: encounter }
  let(:requested_test2)     { RequestedTest.make encounter: encounter2 }
  let!(:microscopy_result)  { MicroscopyResult.make requested_test: requested_test2 }
  let!(:culture_result)     { CultureResult.make requested_test: requested_test }

  let(:nav_context) { NavigationContext.new(current_user, institution.uuid) }

  before do
    TestResult.create_and_index(
    core_fields: {
      'assays' => ['condition' => 'mtb', 'result' => :negative],
      'start_time' => Time.now - 7.days,
      'reported_time' => Time.now+1.hour,
      'name' => 'mtb',
      "type" => "specimen",
      'site_user' => site_user
    },
    device_messages: [DeviceMessage.make(device: user_device)]
    )

    TestResult.create_and_index(
    core_fields: {
      'assays' => ['condition' => 'mtb', 'result' => :negative],
      'start_time' => Time.now - 4.days,
      'reported_time' => Time.now+1.hour,
      'name' => 'mtb',
      "type" => "specimen",
      'site_user' => site_user2
    },
    device_messages: [DeviceMessage.make(device: user_device)]
    )

    refresh_index
  end

  describe 'correct average tests' do
    subject  { Reports::AverageTechnicianTests.new(current_user, nav_context).generate_chart }

    it 'returns a hash with columns' do
      expect(subject).to be_a(Hash)
      expect(subject[:columns].first).to be_a(Hash)
    end

    it 'returns a value for each user' do
      expect(subject[:columns].last[:dataPoints].last[:y]).to eq(3)
    end
  end
end
