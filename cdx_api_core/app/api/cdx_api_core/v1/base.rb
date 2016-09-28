module CdxApiCore
  module V1
    class Base < Grape::API
      mount CdxApiCore::V1::Activation
      add_swagger_documentation
    end
  end
end