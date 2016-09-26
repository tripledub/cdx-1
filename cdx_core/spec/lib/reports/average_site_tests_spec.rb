require 'spec_helper'
RSpec.describe Reports::AverageSiteTests, elasticsearch: true do
  let(:current_user) { User.make }
  let(:institution)  { Institution.make(user_id: current_user.id) }
  let(:site)         { Site.make(institution: institution) }
  let(:site2)        { Site.make(institution: institution) }
  let(:user_device)  { Device.make institution_id: institution.id, site: site }
  let(:user_device_two) do
    Device.make institution_id: institution.id, site: site2
  end

  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution , user: current_user, patient: patient, site: site, test_batch: TestBatch.make(institution: institution) }
  let(:encounter2)          { Encounter.make institution: institution , user: current_user, patient: patient, site: site2, test_batch: TestBatch.make(institution: institution) }
  let!(:microscopy_result)  { MicroscopyResult.make test_batch: encounter2.test_batch }
  let!(:culture_result)     { CultureResult.make test_batch: encounter.test_batch }
  let(:nav_context)         { NavigationContext.new(current_user, institution.uuid) }
  let(:options)             { {} }

  before do
    50.times do
      # create 50 tests in previous 30 days
      # i.e.last month for first site
      start_time = random_day
      TestResult.create_and_index(
        core_fields: {
          'assays' => ['condition' => 'mtb', 'result' => :positive],
          'start_time' => start_time,
          'end_time' => start_time,
          'reported_time' => start_time,
          'type' => 'specimen',
          'name' => 'mtb',
          'status' => 'success'
        },
        device_messages: [DeviceMessage.make(device: user_device)]
      )
      MicroscopyResult.make encounter2.test_batch, created_at: start_time
    end

    30.times do
      # create 30 tests in previous 30 days
      # i.e.last month for site two
      start_time = random_day
      TestResult.create_and_index(
        core_fields: {
          'assays' => ['condition' => 'mtb', 'result' => :positive],
          'start_time' => start_time,
          'end_time' => start_time,
          'reported_time' => start_time,
          'type' => 'specimen',
          'name' => 'mtb',
          'status' => 'success'
        },
        device_messages: [DeviceMessage.make(device: user_device_two)]
      )
    end
    refresh_index
  end

  describe '.show' do
    subject { described_class.new(current_user, nav_context).generate_chart }

    it 'is an array of hashes grouped by site' do
      expect(subject).to be_a(Hash)
      expect(subject[:columns]).to be_a(Array)
      expect(subject[:columns].first).to be_a(Hash)
    end
  end

  def random_day(from = 1, to = 30)
    Time.now - (from..to).to_a.sample.day
  end
end
