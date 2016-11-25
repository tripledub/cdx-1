class RetryJob < ActiveJob::Base
  queue_as :default
  
  def perform(log_id)
    client = Integration::Client.new()
    client.retry(log_id)
  end
end