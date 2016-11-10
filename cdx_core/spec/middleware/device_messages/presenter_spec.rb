require 'spec_helper'

describe DeviceMessages::Presenter do
  let(:user)                { User.make }
  let(:institution)         { user.institutions.make }
  let(:site)                { Site.make institution: institution }
  let(:device_model)        { DeviceModel.make institution: institution }
  let(:device)              { Device.make institution: institution, site: site, device_model: device_model }
  let(:patient)             { Patient.make institution: institution }
  let(:encounter)           { Encounter.make institution: institution, user: user, patient: patient }
  let(:sample)              { Sample.make(institution: institution, patient: patient, encounter: encounter) }
  let(:sample_identifier)   { SampleIdentifier.make(site: site, entity_id: 'sample-id', sample: sample) }
  let(:test_result)         { TestResult.make }
  let!(:messages)           { 14.times { DeviceMessage.make device: device } }
  let(:first_message)       { DeviceMessage.first }

  before :each do
    test_result.institution = institution
    test_result.encounter = sample.encounter
    test_result.site = site
    test_result.patient = patient
    test_result.sample_identifier = sample_identifier
    test_result.device = device
    test_result.save!

    first_message.test_results << test_result
    first_message.save!
  end

  describe 'patient_view' do
    it 'should return an array of formated devices' do
      expect(described_class.index_view(DeviceMessage.all).size).to eq(15)
    end

    it 'should return elements formated' do
      expect(described_class.index_view(DeviceMessage.all).first).to eq(
        id:                first_message.id,
        indexStatus:       {
          failed: 'Failed (reprocess)',
          link: Rails.application.routes.url_helpers.reprocess_device_message_path(first_message)
        },
        failureReason:     first_message.index_failure_reason,
        modelName:         first_message.device.device_model.name,
        deviceName:        first_message.device.name,
        numberOfFailures:  first_message.index_failure_data[:number_of_failures],
        errorField:        first_message.index_failure_data[:target_field],
        createdAt:         Extras::Dates::Format.datetime_with_time_zone(
          first_message.created_at,
          :full_time,
          first_message.device.time_zone
        ),
        testOrderLink:     Rails.application.routes.url_helpers.encounter_path(test_result.encounter),
        rawLink:           Rails.application.routes.url_helpers.raw_device_message_path(first_message)
      )
    end
  end
end
