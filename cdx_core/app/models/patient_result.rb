class PatientResult < ActiveRecord::Base
  include AutoUUID
  include Auditable
  include ActionView::Helpers::DateHelper

  belongs_to :requested_test
  belongs_to :test_batch
  has_many   :assay_results, as: :assayable

  validates_inclusion_of :result_status, in: ['new', 'sample_collected', 'sample_received', 'pending_approval', 'rejected', 'completed'], allow_nil: true

  after_save    :update_batch_status
  before_save   :convert_string_to_dates
  before_save   :complete_test
  before_save   :update_status
  before_create :set_status_to_new

  class << self
    def find_all_for_patient(patient_id)
      PatientResult.joins('LEFT OUTER JOIN `requested_tests` ON `requested_tests`.`id` = `patient_results`.`requested_test_id` LEFT OUTER JOIN `encounters` ON `encounters`.`id` = `requested_tests`.`encounter_id`')
        .where('patient_results.patient_id = ? OR encounters.patient_id = ?', patient_id, patient_id)
    end

    def status_options
      [
        ['new', I18n.t('select.patient_result.status_options.new')],
        ['sample_collected', I18n.t('select.patient_result.status_options.sample_collected')],
        ['sample_received', I18n.t('select.patient_result.status_options.sample_received')],
        ['in_progress', I18n.t('select.patient_result.status_options.in_progress')],
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
    self.result_status = 'in_progress' if result_status == 'new' && serial_number.present?
  end

  def update_batch_status
    return unless self.test_batch

    TestBatches::Persistence.update_status(self.test_batch)
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
