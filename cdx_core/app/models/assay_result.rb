class AssayResult < ActiveRecord::Base
  include AutoUUID
  include NotificationObserver

  belongs_to :assayable, polymorphic: true

  serialize :assay_data, Hash
end
