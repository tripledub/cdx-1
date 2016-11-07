# Xpert results model
class XpertResult < PatientResult
  include NotificationObserver

  validates_presence_of  :sample_collected_at, :examined_by, :tuberculosis, :result_at, on: :update
  validates_presence_of  :rifampicin, if: Proc.new { |xpert_result| xpert_result.tuberculosis == 'detected' }
  validates_inclusion_of :tuberculosis, in: %w(detected not_detected indeterminate no_result err), allow_nil: true
  validates_inclusion_of :rifampicin, in: %w(detected not_detected indeterminate), allow_nil: true
  validates_inclusion_of :result_status, in: %w(new sample_collected allocated pending_approval rejected completed), allow_nil: true
  validate :rifampicin_detected

  notification_observe_fields :result_status, :tuberculosis, :rifampicin

  delegate :patient, to: 'encounter'

  def localised_name
    I18n.t('xpert_results.localised_name')
  end

  def linkable?
    result_status == 'allocated'
  end

  class << self
    def tuberculosis_options
      [
        ['detected', I18n.t('select.xpert.tuberculosis.detected')],
        ['not_detected', I18n.t('select.xpert.tuberculosis.not_detected')],
        ['indeterminate', I18n.t('select.xpert.tuberculosis.indeterminate')],
        ['no_result', I18n.t('select.xpert.tuberculosis.no_result')],
        ['err', I18n.t('select.xpert.tuberculosis.err')]
      ]
    end

    def rifampicin_options
      [
        ['detected', I18n.t('select.xpert.rifampicin.detected')],
        ['not_detected', I18n.t('select.xpert.rifampicin.not_detected')],
        ['indeterminate', I18n.t('select.xpert.rifampicin.indeterminate')]
      ]
    end

    def trace_options
      [
        ['very_low', I18n.t('select.xpert.trace.very_low')],
        ['low', I18n.t('select.xpert.trace.low')],
        ['medium', I18n.t('select.xpert.trace.medium')],
        ['high', I18n.t('select.xpert.trace.high')]
      ]
    end
  end

  protected

  def rifampicin_detected
    errors.add(:rifampicin, I18n.t('xpert_results.form.rifampicin_detected')) if rifampicin == 'detected' && tuberculosis != 'detected'
  end
end
