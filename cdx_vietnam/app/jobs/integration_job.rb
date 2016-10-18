class IntegrationJob < ActiveJob::Base
  queue_as :default
  
  def perform(json)
    client = Integration::Client.new()
    client.integration(json)
  end
end