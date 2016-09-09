class DeviceModel < ActiveRecord::Base

  include Resource

  before_destroy :destroy_devices!

  has_one :manifest, dependent: :destroy, inverse_of: :device_model
  has_many :devices, dependent: :restrict_with_exception

  belongs_to :institution, inverse_of: :device_models

  scope :published,   -> { where.not(published_at: nil) }
  scope :unpublished, -> { where(published_at: nil) }

  validates_uniqueness_of :name

  validates_presence_of :filename_pattern, if: :supports_ftp
  validate :valid_filename_pattern

  accepts_nested_attributes_for :manifest

  #This is kept for forward compatibility (we will have multiple manifests, published and unpublished)
  alias_method :current_manifest, :manifest

  has_attached_file :picture, styles: { card: "180x180>" }, default_url: "card-unkown.png"
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  attr_accessor :delete_picture
  attr_accessor :picture_content_type
  before_validation { picture.clear if delete_picture == '1' }

  has_attached_file :setup_instructions
  validates_attachment_content_type :setup_instructions, :content_type =>['application/pdf'], message: I18n.t('device_model.must_be_pdf')
  attr_accessor :delete_setup_instructions
  attr_accessor :setup_instructions_content_type
  before_validation { setup_instructions.clear if delete_setup_instructions == '1' }

  def full_name
    if institution
      "#{name} (#{institution.name})"
    else
      name
    end
  end

  def published?
    !!published_at
  end

  def set_published_at
    self.published_at ||= DateTime.now
  end

  def unset_published_at
    self.published_at = nil
  end

  private

  def destroy_devices!
    raise ActiveRecord::RecordNotDestroyed, I18n.t('device_model.cannot_destroy_publish_device') if published?
    devices = self.devices.to_a
    raise ActiveRecord::RecordNotDestroyed, I18n.t('device_model.cannot_destroy_device') if devices.any?{|d| d.institution_id != institution_id}
    devices.each(&:destroy_cascade!)
    devices(true) # Reload devices relation so destroy:restrict does not prevent the record from being destroyed
  end

  def valid_filename_pattern
    return if filename_pattern.blank?
    regex = Regexp.new(filename_pattern)
    errors.add(:filename_pattern, "#{I18n.t('device_model.must_capture')} (?<sn>[A-Z0-9]+).*\\.csv") unless regex.names.include?('sn')
  rescue RegexpError => ex
    errors.add(:filename_pattern, "#{I18n.t('device_model.must_be_valid_pattern')} (#{ex.message})")
  end

end
