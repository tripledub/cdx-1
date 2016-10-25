class Notification::Site < ActiveRecord::Base
  acts_as_paranoid

  # Relationships
  belongs_to :site,         inverse_of: :notification_sites, class_name: '::Site'
  belongs_to :notification, inverse_of: :notification_sites

  # Validations
  validates :site,         presence: true
  validates :notification, presence: true
end
