class XpertResult < PatientResult
  validates_presence_of  :requested_test_id, :sample_collected_on, :examined_by, :tuberculosis, :rifampicin, :result_on
  validates_inclusion_of :tuberculosis, in: ['detected', 'not_detected', 'invalid']
  validates_inclusion_of :rifampicin,   in: ['detected', 'not_detected', 'indeterminate']

  validate :rifampicin_detected

  delegate :patient, to: 'requested_test.encounter'

  class << self
    def tuberculosis_options
      [['detected', I18n.t('select.xpert.tuberculosis.detected')], ['not_detected', I18n.t('select.xpert.tuberculosis.not_detected')], ['invalid', I18n.t('select.xpert.tuberculosis.invalid')]]
    end

    def rifampicin_options
      [['detected', I18n.t('select.xpert.rifampicin.detected')], ['not_detected', I18n.t('select.xpert.rifampicin.not_detected')], ['indeterminate', I18n.t('select.xpert.rifampicin.indeterminate')]]
    end

    def trace_options
      [['trace', I18n.t('select.xpert.trace.trace')], ['very_low', I18n.t('select.xpert.trace.very_low')], ['low', I18n.t('select.xpert.trace.low')], ['medium', I18n.t('select.xpert.trace.medium')], ['high', I18n.t('select.xpert.trace.high')]]
    end
  end

  protected

  def rifampicin_detected
    errors.add(:rifampicin, I18n.t('xpert_results.form.rifampicin_detected')) if rifampicin == 'detected' && tuberculosis != 'detected'
  end
end
