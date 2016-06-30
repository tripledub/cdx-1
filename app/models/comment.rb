class Comment < ActiveRecord::Base
  include AutoUUID
  include Auditable

  has_attached_file :image

  belongs_to :patient
  belongs_to :user

  validates_presence_of :description, :commented_on, :patient_id, :user_id

  validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  before_save :add_default_date

  protected

  def add_default_date
    return if commented_on.present?

    commented_on = Date.today
  end
end
