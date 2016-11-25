require 'machinist'

namespace :db do
  desc 'Load dummy test data'
  task :load_test_data, [:how_many] => :environment do |_t, args|
    raise ArgumentError, 'Please indicate how many test orders we should create' unless args[:how_many]
    unless Rails.env.development? || Rails.env.test?
      puts "Belive me.  You don't want to use this task in production"
      exit 1
    end

    require File.expand_path('cdx_core/spec/support/blueprints', Rails.root)

    institution = Institution.first
    site = Site.make institution: institution
    site.save!
    site2 = Site.make institution: institution, parent_id: site.id
    site2.save!
    site3 = Site.make institution: institution, parent_id: site2.id
    site3.save!
    site4 = Site.make institution: institution
    site4.save!
    site5 = Site.make institution: institution
    site5.save!

    sites = [site, site2, site3, site4, site5]



    args[:how_many].to_i.times do
      patient = Patient.make institution: institution, site: sites.sample
      patient.save!
      encounter = Encounter.make institution: institution, site: patient.site, performing_site: sites.sample, patient: patient, start_time: rand(1..399).days.ago.strftime('%Y-%m-%d'), testdue_date: rand(1..99).day.from_now.strftime('%Y-%m-%d')
      encounter.save!
    end

    puts 'Sample data created. Have fun!'
  end
end
