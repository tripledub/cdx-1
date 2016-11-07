class Notification::Device < ActiveRecord::Base

  acts_as_paranoid

  # Relationships
  belongs_to :device, class_name: '::Device'
  belongs_to :notification

  # Validations
  validates :device,       presence: true
  validates :notification, presence: true

end
