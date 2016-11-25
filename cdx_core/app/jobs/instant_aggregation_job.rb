class InstantAggregationJob
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    Notifications::Aggregation::Instant.run
  end
end
