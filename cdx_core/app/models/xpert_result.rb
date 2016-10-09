# Xpert results model
class XpertResult < PatientResult
  validates_presence_of  :sample_collected_on, :examined_by, :tuberculosis, :rifampicin, :result_on, on: :update
  validates_inclusion_of :tuberculosis, in: %w(detected not_detected indeterminate), allow_nil: true
  validates_inclusion_of :rifampicin,   in: %w(detected not_detected indeterminate), allow_nil: true
  validates_inclusion_of :result_status, in: %w(new sample_collected allocated pending_approval rejected completed), allow_nil: true
  validate :rifampicin_detected

  delegate :patient, to: 'encounter'

  def localised_name
    I18n.t('xpert_results.localised_name')
  end

  def is_linkable?
    result_status == 'allocated'
  end

  class << self
    def tuberculosis_options
      [
        ['detected', I18n.t('select.xpert.tuberculosis.detected')],
        ['not_detected', I18n.t('select.xpert.tuberculosis.not_detected')],
        ['indeterminate', I18n.t('select.xpert.tuberculosis.indeterminate')]
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
        ['trace', I18n.t('select.xpert.trace.trace')],
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
