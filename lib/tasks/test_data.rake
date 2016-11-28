require 'machinist'

namespace :db do
  desc 'Load dummy test data'
  task :load_test_data, [:how_many] => :environment do |_t, args|
    raise ArgumentError, 'Please indicate how many test orders we should create' unless args[:how_many]
    unless Rails.env.development? || Rails.env.test?
      puts "Belive me.  You don't want to use this task in production"
      exit 1
    end

    require File.expand_path('cdx_core/spec/support/default_manifest', Rails.root)
    require File.expand_path('cdx_core/spec/support/blueprints', Rails.root)

    institution = Institution.first
    # site = Site.make institution: institution
    # site.save!
    # site2 = Site.make institution: institution, parent_id: site.id
    # site2.save!
    # site3 = Site.make institution: institution, parent_id: site2.id
    # site3.save!
    # site4 = Site.make institution: institution
    # site4.save!
    # site5 = Site.make institution: institution
    # site5.save!
    # device_model = DeviceModel.make institution: institution
    # device_model.save!
    # device_model2 = DeviceModel.make institution: institution
    # device_model2.save!
    #
    # Site.all.each do |site|
    #   device = Device.make site: site, institution: institution, device_model: DeviceModel.all.sample
    #   device.save!
    # end

    # args[:how_many].to_i.times do
    #   patient = Patient.make institution: institution, site: Site.all.sample
    #   patient.save!
    #   encounter = Encounter.make institution: institution, site: patient.site, performing_site: Site.all.sample, patient: patient, start_time: rand(1..399).days.ago.strftime('%Y-%m-%d'), testdue_date: rand(1..99).day.from_now.strftime('%Y-%m-%d')
    #   encounter.save!
    # end

    args[:how_many].to_i.times do
      status = %w(success error no_result invalid)
      device_message = DeviceMessage.make device: Device.all.sample
      device_message.save!
      offset = rand(Patient.count)
      patient = Patient.offset(offset).first
      random_date = rand(1..399).days.ago.strftime('%Y-%m-%d %H:%M')
      test_result = TestResult.make institution: institution, patient: patient, sample_collected_at: random_date, result_at: random_date, device_messages: [device_message], result_status: status.sample, result_type: 'specimen'
      test_result.save!
      [1, 2, 3].sample.times do
        assay_result = AssayResult.make assayable: test_result
        assay_result.save!
      end
    end

    puts 'Sample data created. Have fun!'
  end
end
