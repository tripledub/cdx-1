class AssayResult < ActiveRecord::Base
  include AutoUUID

  belongs_to :assayable, polymorphic: true
end
