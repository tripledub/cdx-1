class IntegrationLog < ActiveRecord::Base
  serialize :json, JSON
end
