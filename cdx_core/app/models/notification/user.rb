class Notification::User < ActiveRecord::Base
  acts_as_paranoid

  # Relationships
  belongs_to :user,         inverse_of: :notification_users, class_name: '::User'
  belongs_to :notification, inverse_of: :notification_users

  # Validations
  validates :user,         presence: true
  validates :notification, presence: true
end
