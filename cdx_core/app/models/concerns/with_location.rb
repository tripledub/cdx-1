module WithLocation
  extend ActiveSupport::Concern

  included do
    def location(opts={})
      return nil if self.location_geoid.blank?
      @location = nil if @location_opts.presence != opts.presence || @location.try(:geo_id) != location_geoid
      @location_opts = opts
      @location ||= Location.find(location_geoid, opts)
    end

    def location=(value)
      @location = value
      self.location_geoid = value.try(:id)
    end

    def self.preload_locations!
      return []
    end
  end
end
