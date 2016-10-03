class Notification::Status < ActiveRecord::Base
  acts_as_paranoid

  # Relationships
  belongs_to :notification, inverse_of: :notification_statuses

  # Validations
  validates :test_status,  presence: true, uniqueness: { scope: :notification_id }
  validates :notification, presence: true
end
