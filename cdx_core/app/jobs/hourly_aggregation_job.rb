class HourlyAggregationJob
  include Sidekiq::Worker

  def perform
    Notifications::Aggregation::Targeted.run
    Notifications::Aggregation::Hourly.run
    Notifications::Aggregation::Daily.run
    Notifications::Aggregation::Weekly.run

  end
end

Sidekiq::Cron::Job.create(name: 'Hourly Aggregation Job', cron: '0 * * * *', klass: 'HourlyAggregationJob')
