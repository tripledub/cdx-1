class Notification::Condition < ActiveRecord::Base
  acts_as_paranoid

  TYPES = %w(
    Encounter
    CultureResult
    DstLpaResult
    MicroscopyResult
    XpertResult
  )

  # Relationships
  belongs_to :notification

#  has_many :notification_statuses

  # Validations
  validates :condition_type, inclusion: { in: TYPES }

  attr_writer :notification_statuses_names

#  after_save :create_notification_statuses

#  def notification_statuses_names
#    @notification_statuses_names ||= notification_statuses.pluck(:test_status)
#  end
#
#  def create_notification_statuses
#    return if notification_statuses_names.blank?
#    # Remove empty strings and nils
#    notification_statuses_names.reject!(&:blank?)
#    # Get current test statuses from relation
#    current_test_statuses  = notification_statuses.pluck(:test_status)
#    # New test statuses
#    adding_test_statuses   = notification_statuses_names - current_test_statuses
#    # Removed test statuses
#    removing_test_statuses = current_test_statuses - notification_statuses_names
#    # Create all new statuses
#    notification_statuses.create!(adding_test_statuses.map { |test_status| { test_status: test_status } })
#    # Destroy all removed statuses
#    notification_statuses.where(test_status: removing_test_statuses).destroy_all
#  end
#
  def self.condition_type_select_options
    TYPES.map {|t| [t.constantize.model_name.human, t]}
  end

  def self.field_select_options
    @@field_select_options ||= begin
      Hash.new.tap do |h|
        TYPES.each { |t| h[t] = t.constantize._notification_observed_fields.map { |value| { id: value, text: t.constantize.human_attribute_name(value.to_sym) } } }
      end
    end
  end

  def self.field_select_statuses
    @@field_select_statuses ||= begin
      Hash.new.tap do |h|
        TYPES.each do |t|
          next unless t.constantize.respond_to?(:status_options)
          h[t] = t.constantize.status_options.map { |key, value| { id: key, text: value } }
        end
      end
    end
  end
end
