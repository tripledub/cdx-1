class Notification < ActiveRecord::Base
  include Resource
  include SiteContained

  acts_as_paranoid

  ANOMALY_TYPES = [
    [I18n.t('select.notification.anomaly_type.missing_sample_id'), 'missing_sample_id'],
    [I18n.t('select.notification.anomaly_type.invalid_test_date'), 'invalid_test_date']
  ]

  FREQUENCY_TYPES = [
    [I18n.t('select.notification.frequency.instant'),   'instant'],
    [I18n.t('select.notification.frequency.aggregate'), 'aggregate'],
    [I18n.t('select.notification.frequency.targeted'),  'targeted']
  ]

  FREQUENCY_VALUES = [
    [I18n.t('select.notification.frequency.instant'),   'instant'],
    [I18n.t('select.notification.frequency_value.hourly'),  'hourly'],
    [I18n.t('select.notification.frequency_value.daily'),   'daily'],
    [I18n.t('select.notification.frequency_value.weekly'),  'weekly'],
    [I18n.t('select.notification.frequency_value.monthly'), 'monthly']
  ]

  # Relationships
  belongs_to :institution
  belongs_to :encounter
  belongs_to :patient
  belongs_to :user, class_name: '::User'

  has_many :notification_sites,   class_name: 'Notification::Site'
  has_many :notification_devices, class_name: 'Notification::Device'
  has_many :notification_roles,   class_name: 'Notification::Role'
  has_many :notification_users,   class_name: 'Notification::User'

  has_many :sites,   through: :notification_sites,   class_name: '::Site'
  has_many :devices, through: :notification_devices, class_name: '::Device'
  has_many :roles,   through: :notification_roles,   class_name: '::Role'
  has_many :users,   through: :notification_users,   class_name: '::User'

  has_many :notification_conditions, class_name: 'Notification::Condition'
  has_many :notification_recipients, class_name: 'Notification::Recipient'
  has_many :notification_statuses,   class_name: 'Notification::Status'
  has_many :notification_notices,    class_name: 'Notification::Notice'

  # Validations
  validates :institution,         presence:  true
  validates :user,                presence:  true
  validates :patient,             presence:  { if: :on_patient }
  validates :encounter,           presence:  { if: :on_test_order }
  validates :name,                presence:  true
  validates :frequency,           presence:  true
  validates :email_message,       presence:  { if: :email }
  validates :sms_message,         presence:  { if: :sms }
  validates :anomaly_type,        inclusion: { in: Notification::ANOMALY_TYPES.map(&:last) },
                                  allow_nil: true, allow_blank: true
  validates :frequency,           inclusion: { in: Notification::FREQUENCY_TYPES.map(&:last) }
  validates :frequency_value,     presence:  { if: :aggregate? },
                                  inclusion: { in: Notification::FREQUENCY_VALUES.map(&:last) },
                                  allow_nil: true, allow_blank: true
  validates :detection_condition, presence:  { if: :detection? }

  alias_attribute :utilisation_efficiency_sample_identifier, :sample_identifier

  accepts_nested_attributes_for :notification_conditions, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :notification_recipients, reject_if: :all_blank, allow_destroy: true

  # Callbacks
  before_validation :enforce_nil_values
  before_validation :patient_lookup
  before_validation :test_lookup

  def notification_statuses_names
    @notification_statuses_names ||= notification_statuses.pluck(:test_status)
  end

  # Scopes
  scope :enabled, -> { where(enabled: true) }
  scope :within,  -> (institution_or_site, exclude_subsites = false) {
    if institution_or_site.is_a?(Institution) && exclude_subsites
      where("notifications.institution_id = ? AND notifications.site_id IS NULL", institution_or_site.id)
    elsif institution_or_site.is_a?(Institution) && !exclude_subsites
      where("notifications.institution_id = ?", institution_or_site.id)
    elsif institution_or_site.is_a?(Site) && exclude_subsites
      where("notifications.site_id = ?", institution_or_site.id)
    else
      where("notifications.site_prefix LIKE concat(?, '%')", institution_or_site.prefix)
    end
  }

  # Instance methods
  def on_patient
    patient_identifier.present?
  end

  def on_test_order
    test_identifier.present?
  end

  def detection?
    detection.present?
  end

  def instant?
    frequency == 'instant'
  end

  def aggregate?
    frequency == 'aggregate'
  end

  def role_users
    @role_users ||= ::User.includes(roles: { notification_roles: [:notification] }).where(notifications: { id: id} )
  end

  private

  def patient_lookup_entity_id
    # Strict lookup based on #patient_identifier and Patient#entity_id
    Patient.where(is_phantom: false, institution_id: institution_id)
           .find_by(entity_id: patient_identifier)
  end

  def patient_lookup_id
    # Regex off the last set of digits.
    # i.e. 00001 off of CDP00001
    return if (matches = patient_identifier.match(/(\d+\b)/)).blank?

    Patient.where(is_phantom: false, institution_id: institution_id)
           .find_by(id: matches[0].to_i)
  end

  # TODO: Change this drastically to use ui search lookup.
  def patient_lookup
    return unless patient_identifier_changed?
    self.patient = patient_lookup_entity_id || patient_lookup_id
  end

  # TODO: Change this drastically to use ui search lookup.
  def test_lookup
    return if test_identifier.blank?
    return if (matches = test_identifier.match(/(\d+\b)/)).blank?

    encounters = patient ? patient.encounters : Encounter
    self.encounter = encounters.where(is_phantom: false, institution_id: institution_id)
                               .find_by(id: matches[0].to_i)
  end

  # The Lookup for notifications queries on NULL, not on an empty string.
  def enforce_nil_values
    self.sample_identifier = nil             if self.sample_identifier.blank?
    self.detection = nil                     if self.detection.blank?
    self.detection_condition = nil           if self.detection_condition.blank?
    self.detection_quantitative_result = nil if self.detection_quantitative_result.blank?
  end
end

# I got a long way into this before I found out the engine stuff
# is breaking the tests massively without the following requires.
require_dependency 'notification/device'
require_dependency 'notification/condition'
require_dependency 'notification/notice'
require_dependency 'notification/notice_group'
require_dependency 'notification/notice_recipient'
require_dependency 'notification/recipient'
require_dependency 'notification/role'
require_dependency 'notification/site'
require_dependency 'notification/status'
require_dependency 'notification/user'
