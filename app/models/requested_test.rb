class RequestedTest < ActiveRecord::Base
  include Auditable
  include ActionView::Helpers::DateHelper

  belongs_to :encounter

  acts_as_paranoid

  has_one :xpert_result
  has_one :microscopy_result
  has_one :dst_lpa_result
  has_one :culture_result

  validates_presence_of :comment, if: Proc.new { |rt| rt.status == 'rejected' }, message: I18n.t('requested_test.validations.rejected_no_comment')

  validates_presence_of :name
  enum status: [:pending, :inprogress, :completed, :rejected]

  delegate :patient, to: :encounter

  before_save :update_completed_status
  after_save :update_encounter_status

  class << self
    def show_dst_warning
      dst_new     = false
      culture_new = false

      all.each do |requested_test|
        dst_new     = !requested_test.dst_lpa_result.present? if requested_test.name == 'dst'
        culture_new = !requested_test.culture_result.present? if requested_test.name == 'culture'
      end

      dst_new && culture_new
    end
  end

  def result_type
    if culture_result.present?
      return I18n.t('requested_test.result.culture')
    elsif xpert_result.present?
      return I18n.t('requested_test.result.xpert')
    elsif microscopy_result.present?
      return I18n.t('requested_test.result.microscopy')
    elsif dst_lpa_result.present?
      return I18n.t('requested_test.result.dst_lpa')
    end
  end

  def turnaround
    return I18n.t('requested_test.incomplete') unless completed_at
    distance_of_time_in_words(created_at, completed_at)
  end

  def update_completed_status
    self.completed_at = Time.now if status == 'completed'
  end

  def update_encounter_status
    EncounterStatus.change_status(encounter)
  end
end
