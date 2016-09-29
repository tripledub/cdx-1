# Patient results model
class PatientResult < ActiveRecord::Base
  include AutoUUID
  include Auditable
  include ActionView::Helpers::DateHelper

  belongs_to :encounter
  belongs_to :feedback_message
  has_many   :assay_results, as: :assayable
  has_many   :audit_logs

  validates_presence_of :comment, if: Proc.new { |rt| rt.result_status == 'rejected' }, message: I18n.t('patient_results.validations.rejected_no_comment')

  after_save    :update_batch_status
  before_save   :convert_string_to_dates
  before_save   :complete_test
  before_save   :update_status
  before_create :set_status_to_new

  acts_as_paranoid

  scope :pending_approval, -> { where(result_status: 'pending_approval') }

  class << self
    def find_all_results_for_patient(patient_id)
      PatientResult.joins(:encounter).where('patient_results.patient_id = ? OR encounters.patient_id = ?', patient_id, patient_id)
    end

    def status_options
      [
        ['new', I18n.t('select.patient_result.status_options.new')],
        ['sample_collected', I18n.t('select.patient_result.status_options.sample_collected')],
        ['sample_received', I18n.t('select.patient_result.status_options.sample_received')],
        ['pending_approval', I18n.t('select.patient_result.status_options.pending_approval')],
        ['rejected', I18n.t('select.patient_result.status_options.rejected')],
        ['completed', I18n.t('select.patient_result.status_options.completed')]
      ]
    end
  end

  def test_name
    [localised_name, format_name].compact.join(' ')
  end

  def turnaround
    return I18n.t('patient_result.incomplete') unless completed_at
    distance_of_time_in_words(created_at, completed_at)
  end

  protected

  def convert_string_to_dates
    sample_collected_on = Extras::Dates::Format.string_to_pattern(sample_collected_on) if sample_collected_on.present? && sample_collected_on.is_a?(String)
    result_on           = Extras::Dates::Format.string_to_pattern(result_on) if result_on.present? && result_on.is_a?(String)
  end

  def complete_test
    self.completed_at = Time.now if result_status == 'completed'
  end

  def update_status
    self.result_status = 'sample_collected' if result_status == 'new' && serial_number.present?
  end

  def update_batch_status
    return unless encounter.present?

    TestOrders::Status.update_status(encounter)
  end

  def set_status_to_new
    self.result_status = 'new'
  end

  def format_name
    return unless result_name

    if result_name.include? 'solid'
      I18n.t('select.culture.media_options.solid')
    elsif result_name.include? 'liquid'
      I18n.t('select.culture.media_options.liquid')
    end
  end
end
