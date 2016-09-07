LocationService.setup do |config|
  config.url = Settings.location_service_url
  config.set = Settings.location_service_set
  config.logger = Rails.logger
end

Location
require File.join("#{CdxApiCore::Engine.root}", '../cdx_core/app/models/location')
