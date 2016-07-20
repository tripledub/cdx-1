class Comment < ActiveRecord::Base
  include AutoUUID
  include Auditable

  has_attached_file :image

  belongs_to :patient
  belongs_to :user

  validates_presence_of :description, :patient_id, :user_id

  validates_attachment :image, content_type: { content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif', 'application/pdf'] }
end
