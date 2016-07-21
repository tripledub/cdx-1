require 'spec_helper'

RSpec.describe Reports::Site, elasticsearch: true do
  let(:current_user)        { User.make }
  let(:site_user)           { "#{current_user.first_name} #{current_user.last_name}" }
  let(:institution)         { Institution.make(user_id: current_user.id) }
  let(:site)                { Site.make(institution: institution, name: 'The Site') }
  let(:site2)               { Site.make(institution: institution, name: 'The Second Site') }
  let(:user_device)         { Device.make institution_id: institution.id, site: site }
  let(:user_device_two)     { Device.make institution_id: institution.id, site: site2 }
  let(:nav_context)         { NavigationContext.new(current_user, institution.uuid) }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: current_user, patient: patient, site: site }
  let(:encounter2)          { Encounter.make institution: institution , user: current_user, patient: patient, site: site2 }
  let(:requested_test)      { RequestedTest.make encounter: encounter }
  let(:requested_test2)     { RequestedTest.make encounter: encounter2 }
  let!(:microscopy_result)  { MicroscopyResult.make requested_test: requested_test2 }
  let!(:culture_result)     { CultureResult.make requested_test: requested_test }

  before do
    TestResult.create_and_index(
      core_fields: {
        'assays' => ['condition' => 'mtb', 'result' => :positive],
        'start_time' => Time.now,
        'name' => 'mtb',
        'status' => 'error',
        'error_code' => 300,
        'type' => 'specimen',
        'site_user' => site_user
      },
      device_messages: [DeviceMessage.make(device: user_device)]
    )

    TestResult.create_and_index(
      core_fields: {
        'assays' => ['condition' => 'mtb', 'result' => :negative],
        'start_time' => Time.now - 1.month,
        'name' => 'mtb',
        'status' => 'error',
        'error_code' => 300,
        'type' => 'specimen',
        'site_user' => site_user
      },
      device_messages: [DeviceMessage.make(device: user_device)]
    )

    TestResult.create_and_index(
      core_fields: {
        'assays' => ['condition' => 'man_flu', 'result' => :negative],
        'start_time' => Time.now - 1.month,
        'name' => 'man_flu',
        'status' => 'error',
        'error_code' => 200,
        'type' => 'specimen'
      },
      device_messages: [DeviceMessage.make(device: user_device_two)]
    )

    refresh_index
  end

  describe 'process results' do
    subject { Reports::Site.new(current_user, nav_context).generate_chart }

    it 'can sort results by site' do
      expect(subject[:columns].last[:y]).to eq(2)
      expect(subject[:columns].last[:label]).to eq(site.name)
    end
  end
end
