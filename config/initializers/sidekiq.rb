# Send calls to Rails.logger to
# Sidekiq::Logging.logger when you're spawned from a job
Sidekiq.configure_server do |config|
  Rails.logger = Sidekiq::Logging.logger

  schedule_file = "config/sidekiq_schedule.yml"
  if File.exists?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end
