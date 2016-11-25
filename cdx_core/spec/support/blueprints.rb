require 'machinist/active_record'
require 'sham'
require 'faker'

class Sham
  # Emulates Machinist 2 serial number
  def self.sn
    @sn ||= 0
    @sn += 1
  end
end

SampleSshKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4'+
          'hzyCbJQ5RgrZPFz+rTscTuJ5NPuBIKiinXwkA38CE9+N37L8q9kMqxsbDumVFbamYVlS9fsmF1TqRRhobfJfZGpt'+
          'kcthQde83FWHQGaEQn8T4SG055N5SWNRjQTfMaK0uTTQ28BN44dhLluF/zp4UDHOKRVBrJY4SZq1M5ytkMc6mlZW'+
          'bCAzqtIUUJOMKz4lHn5Os/d8temlYskaKQ1n+FuX5qJXNr1SW8euH72fjQndu78DCwVNwnnrG+nEe3a9m2QwL5xn'+
          'X8f1ohAZ9IG41hwIOvB5UcrFenqYIpMPBCCOnizUcyIFJhegJDWh2oWlBo041emGOX3VCRjtGug3 fbulgarelli@Manass-MacBook-2.local'

Sham.define do
  name { Faker::Name.name }
  email { Faker::Internet.email }
  password { Faker::Name.name }
  url { Faker::Internet.url }
end

User.blueprint do
  email
  password
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  password_confirmation { password }
  confirmed_at { Time.now - 1.day }
end

User.blueprint(:with_contacts) do
  telephone { Faker::PhoneNumber.phone_number }
end

Comment.blueprint do
  patient       { Patient.make }
  commented_on  { Faker::Date.between(60.days.ago, Date.today) }
  user          { User.make }
  description   { Faker::Lorem.sentence }
  comment       { Faker::Lorem.paragraph }
end

FeedbackMessage.blueprint do
  category Faker::Lorem.word
  code Faker::Lorem.word
end

CustomTranslation.blueprint do
  lang { 'en' }
  text { Faker::Lorem.sentence }
end

AuditLog.blueprint do
  patient       { Patient.make }
  user          { User.make }
  title         { Faker::Lorem.sentence }
  comment       { Faker::Lorem.paragraph }
end

AuditUpdate.blueprint do
  field_name    { Faker::Lorem.word }
  old_value     { Faker::Lorem.word }
  new_value     { Faker::Lorem.word }
  audit_log     { AuditLog.make }
end

User.blueprint(:invited_pending) do
  confirmed_at nil
  invitation_token { SecureRandom.urlsafe_base64 }
  invitation_created_at 1.day.ago
  invitation_sent_at 1.day.ago
  invitation_accepted_at nil
end

Institution.blueprint do
  user
  name
end

Institution.blueprint(:with_contacts) do
  user :with_contacts
end

Institution.blueprint(:manufacturer) do
  kind { "manufacturer" }
end

Device.blueprint do
  site { Site.make(institution: (object.institution || Institution.make)) }
  institution { object.site.try(:institution) || Institution.make }
  name
  serial_number { SecureRandom.urlsafe_base64 }
  device_model { Manifest.make.device_model }
  time_zone { "UTC" }
end

DeviceLog.blueprint do
  device
end

DeviceCommand.blueprint do
  device
end

DeviceModel.blueprint do
  name
  published_at { 1.day.ago }
end

DeviceModel.blueprint(:unpublished) do
  name
  published_at { nil }
end

Manifest.blueprint do
  device_model
  definition { DefaultManifest.definition }
end

PageHeader.blueprint do
  institution { Institution.make }
end

SettingsPage.blueprint do
  institution { Institution.make }
end

Encounter.blueprint do
  patient { Patient.make }
  institution { object.patient.try(:institution) || Institution.make }
  user { institution.user }
  status 'new'
  site { object.institution.sites.first || object.institution.sites.make }
  performing_site { object.institution.sites.first || object.institution.sites.make }
  core_fields do
    { "id" => "encounter-#{Sham.sn}" }.tap do |h|
      h["start_time"] = object.start_time if object.start_time
    end
  end
end

Episode.blueprint do
  diagnosis :presumptive_tb
  hiv_status :unknown
  drug_resistance :mono
  initial_history :previous
  previous_history :relapsed
  outcome :cured
end

SampleIdentifier.blueprint do
  sample { Sample.make_unsaved({}.tap do |h|
    h[:institution] = object.site.institution if object.site
  end) }
  site { sample.institution.sites.first || sample.institution.sites.make }
end

Sample.blueprint do
  institution { object.encounter.try(:institution) || object.patient.try(:institution) || Institution.make }
  patient { object.encounter.try(:patient) }
end

Patient.blueprint do
  name Faker::Name.name
  institution
  is_phantom { false }
  plain_sensitive_data {
    {}.tap do |h|
      h["id"]   = object.entity_id || "patient-#{Sham.sn}"
      h["name"] = object.name if object.name
    end
  }
end

Address.blueprint do
  address  { Faker::Address.street_address }
  city     { Faker::Address.city }
  state    { Faker::Address.state }
  country  { Faker::Address.country }
  zip_code { Faker::Address.zip_code }
end

Patient.blueprint :phantom do
  institution
  is_phantom { true }
  plain_sensitive_data {
    {}.tap do |h|
      h["id"]   = nil
      h["name"] = object.name if object.name
    end
  }
end

TestResult.blueprint do
  test_id { "test-#{Sham.sn}" }

  device_messages { [ DeviceMessage.make(device: object.device || Device.make) ] }
  device { object.device_messages.first.try(:device) || Device.make }
  institution { object.device.try(:institution) || Institution.make }
  sample_identifier { SampleIdentifier.make(site: object.device.try(:site), sample: Sample.make(institution: object.institution, patient: object.patient, encounter: object.encounter)) }

  encounter { object.sample.try(:encounter) }
  patient { object.sample.try(:patient) || object.encounter.try(:patient) }
  sample_collected_at { Time.now }
  result_at { Time.now }
end

CultureResult.blueprint do
  sample_collected_at { 23.days.ago}
  serial_number { 'some random serial numbers' }
  media_used { 'solid' }
  test_result { 'contaminated' }
  examined_by { Faker::Name.name }
  result_at { 7.days.from_now }
end

DstLpaResult.blueprint do
  sample_collected_at { 23.days.ago}
  serial_number { 'some random serial numbers' }
  media_used { 'solid' }
  method_used { 'direct' }
  results_h { 'resistant' }
  results_r  { 'resistant' }
  results_e { 'susceptible' }
  results_s { 'contaminated'}
  results_amk { 'not_done' }
  results_km { 'contaminated' }
  results_cm {'not_done' }
  results_fq { 'susceptible' }
  results_other1 'Some other things'
  examined_by { Faker::Name.name }
  result_at { 7.days.from_now }
end

MicroscopyResult.blueprint do
  sample_collected_at { 23.days.ago}
  serial_number { 'some random serial numbers' }
  appearance { 'blood' }
  specimen_type { 'some type' }
  test_result { '1to9' }
  examined_by { Faker::Name.name }
  result_at { 7.days.from_now }
end

XpertResult.blueprint do
  sample_collected_at { 23.days.ago}
  tuberculosis { 'detected' }
  rifampicin { 'not_detected' }
  examined_by { Faker::Name.name }
  result_at { 7.days.from_now }
end

AssayResult.blueprint do
  assayable { TestResult.make }
  name      { Faker::Name.name }
  condition { ['mtb', 'rif'].sample }
  result    { ['positive', 'negative'].sample }
  quantitative_result { [nil, 'HIGH', 'LOW', 'MEDIUM', 'VERY LOW'].sample }
  assay_data {
      { condition: object.condition, result: object.result, quantitative_result: object.quantitative_result }
  }
end

DeviceMessage.blueprint do
  device
end

Policy.blueprint do
  name
  granter { Institution.make.user }
  definition { policy_definition(object.granter.institutions.first, Policy::Actions::CREATE_INSTITUTION, true) }
  user
end

Role.blueprint do
  name
  policy
  institution
  site { Site.make institution: object.institution }
end

Site.blueprint do
  institution
  name
  address { Faker::Address.street_address }
  city { Faker::Address.city }
  state { Faker::Address.state }
  zip_code { Faker::Address.zip_code }
  country { Faker::Address.country }
  region { Faker::Address.state }
  lat { rand(-180..180) }
  lng { rand(-90..90) }
end

Site.blueprint :child do
  parent { nil }
  institution { parent.institution }
end

Notification.blueprint do
  institution
  encounter { nil }
  user
  patient { nil }
  name { Faker::Name.name }
  description { Faker::Lorem.sentence(10, true) }
  enabled { true }
  test_identifier { nil }
  sample_identifier { nil }
  patient_identifier { nil }
  detection { nil }
  detection_condition { nil }
  detection_quantitative_result { nil }
  device_error_code { nil }
  anomaly_type { nil }
  utilisation_efficiency_threshold { nil }
  utilisation_efficiency_last_checked_at { nil }
  frequency { Notification::FREQUENCY_TYPES.map(&:last).sample }
  frequency_value { object.frequency == 'aggregate' ? Notification::FREQUENCY_VALUES.map(&:last).sample : nil }
  email { true }
  email_message { Faker::Lorem.sentence(10, true) }
  email_limit { 100 }
  sms { true }
  sms_message { Faker::Lorem.sentence(10, true) }
  sms_limit { 100 }
  site { nil }
  site_prefix { nil }
  last_notification_at { nil }
end

Notification.blueprint(:instant) do
  frequency { 'instant' }
  frequency_value { nil }
end

Notification::Notice.blueprint do
  notification { Notification.make }
  alertable { Encounter.make }
  status { 'pending' }
end

Notification::Status.blueprint do
  notification
  test_status Encounter.status_options.map(&:reverse).sample.last
end

Notification::Condition.blueprint do
  notification
  condition_type { nil }
  field { nil }
  value { nil }
end



Notification::Device.blueprint do
  device
  notification
end

Notification::NoticeGroup.blueprint do
  email_data { { Faker::Internet.email => 1 } }
  telephone_data { { Faker::PhoneNumber.phone_number => 1 } }
  status { 'pending' }
  frequency { Notification::FREQUENCY_TYPES.map(&:last).sample }
  frequency_value { object.frequency == 'aggregate' ? Notification::FREQUENCY_VALUES.map(&:last).sample : nil }
  triggered_at { Time.now }
end

Notification::NoticeRecipient.blueprint do
  notification { Notification.make }
  notification_notice { Notification::Notice.make(notification: object.notification, alertable: Encounter.make) }
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  email { Faker::Internet.email  }
  telephone { Faker::PhoneNumber.phone_number }
  status { 'pending' }
end

Notification::Recipient.blueprint do
  notification
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  email { Faker::Internet.email  }
  telephone { Faker::PhoneNumber.phone_number }
end

Notification::Role.blueprint do
  role
  notification
end

Notification::Site.blueprint do
  notification
end

Notification::User.blueprint do
  notification
  user
end
