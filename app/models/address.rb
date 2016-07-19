class Address < ActiveRecord::Base
  include AutoUUID
  include Auditable

  belongs_to :addressable, :polymorphic => true
end
