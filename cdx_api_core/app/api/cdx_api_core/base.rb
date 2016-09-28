module CdxApiCore
  class Base < Grape::API

    format :json

    rescue_from :all

    # V1 Should emulate current controller driven API.
    mount CdxApiCore::V1::Base

  end
end
