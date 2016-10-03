class AssayResult < ActiveRecord::Base
  include AutoUUID
  include NotificationObserver

  belongs_to :assayable, polymorphic: true

  notification_observe_field :condition
  notification_observe_field :result
  notification_observe_field :quantitative_result

  serialize :assay_data, Hash
end
