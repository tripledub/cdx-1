class MonthlyAggregationJob
  include Sidekiq::Worker

  def perform
    Notifications::Aggregation::Monthly.run
  end
end
