class MonthlyAggregationJob
  include Sidekiq::Worker

  def perform
    Notifications::Aggregation::Monthly.run
  end
end

Sidekiq::Cron::Job.create(name: 'Monthly Aggregation Job', cron: '0 * 1 * *', klass: 'MonthlyAggregationJob')
