class XpertResult < PatientResult
  validates_presence_of  :sample_collected_on, :examined_by, :tuberculosis, :rifampicin, :result_on
  validates_inclusion_of :tuberculosis, in: ['detected', 'not_detected', 'invalid']
  validates_inclusion_of :rifampicin,   in: ['detected', 'not_detected', 'indeterminate']

  delegate :patient, to: 'requested_test.encounter'

  class << self
    def tuberculosis_options
      [['detected', I18n.t('select.xpert.tuberculosis.detected')], ['not_detected', I18n.t('select.xpert.tuberculosis.not_detected')], ['invalid', I18n.t('select.xpert.tuberculosis.invalid')]]
    end

    def rifampicin_options
      [['detected', I18n.t('select.xpert.rifampicin.detected')], ['not_detected', I18n.t('select.xpert.rifampicin.not_detected')], ['indeterminate', I18n.t('select.xpert.rifampicin.indeterminate')]]
    end
  end
end
