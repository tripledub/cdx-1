class CultureResult < PatientResult
  validates_presence_of  :requested_test_id, :sample_collected_on, :examined_by, :result_on, :media_used, :serial_number, :test_result
  validates_inclusion_of :test_result, in: ['negative', '1to9', '1plus', '2plus', '3plus', 'ntm', 'contaminated']
  validates_inclusion_of :media_used, in: ['solid', 'liquid']

  delegate :patient, to: 'requested_test.encounter'

  class << self
    def media_options
      [
        ['solid', I18n.t('select.culture.media_options.solid')],
        ['liquid', I18n.t('select.culture.media_options.liquid')]
      ]
    end

    def test_result_options
      [
        ['negative',     I18n.t('select.microscopy.test_result_options.negative')],
        ['1to9',         I18n.t('select.microscopy.test_result_options.1to9')],
        ['1plus',        I18n.t('select.microscopy.test_result_options.1plus')],
        ['2plus',        I18n.t('select.microscopy.test_result_options.2plus')],
        ['3plus',        I18n.t('select.microscopy.test_result_options.3plus')],
        ['ntm',          I18n.t('select.culture.test_result_options.ntm')],
        ['contaminated', I18n.t('select.culture.test_result_options.contaminated')]
      ]
    end
  end
end
