class Notification::Role < ActiveRecord::Base
  acts_as_paranoid

  # Relationships
  belongs_to :role,         inverse_of: :notification_roles, class_name: '::Role'
  belongs_to :notification, inverse_of: :notification_roles

  # Validations
  validates :role,         presence: true
  validates :notification, presence: true
end
