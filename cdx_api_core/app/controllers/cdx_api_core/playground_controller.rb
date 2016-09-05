module CdxApiCore
  class PlaygroundController < CdxApiCore::ApiController
    layout 'api'

    def index
      @devices = check_access(Device, READ_DEVICE)
    end

    def simulator
      @devices = check_access(Device, READ_DEVICE)
    end
  end
end
