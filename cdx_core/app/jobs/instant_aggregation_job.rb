class InstantAggregationJob
  include Sidekiq::Worker

  def perform
    Notifications::Aggregation::Instant.run
  end
end
