class DstLpaResult < PatientResult
  validates_presence_of  :requested_test_id, :sample_collected_on, :examined_by, :result_on, :media_used, :serial_number, :results_h, :results_r, :results_e, :results_s, :results_amk, :results_km, :results_cm, :results_fq
  validates_inclusion_of :results_h, :results_r, :results_e, :results_s, :results_amk, :results_km, :results_cm, :results_fq, in: ['resistant', 'susceptible', 'contaminated', 'not_done']
  validates_inclusion_of :media_used, in: %w(solid liquid)
  validates_inclusion_of :method_used, in: %w(direct indirect)

  delegate :patient, to: 'requested_test.encounter'

  class << self
    def dst_lpa_options
      [['not_selected', I18n.t('select.dst_lpa.dst_lpa_options.not_selected_long'), I18n.t('select.dst_lpa.dst_lpa_options.not_selected')], ['resistant', I18n.t('select.dst_lpa.dst_lpa_options.resistant_long'), I18n.t('select.dst_lpa.dst_lpa_options.resistant')], ['susceptible', I18n.t('select.dst_lpa.dst_lpa_options.susceptible_long'), I18n.t('select.dst_lpa.dst_lpa_options.susceptible')], ['contaminated', I18n.t('select.dst_lpa.dst_lpa_options.contaminated_long'), I18n.t('select.dst_lpa.dst_lpa_options.contaminated')], ['not_done', I18n.t('select.dst_lpa.dst_lpa_options.not_done_long'), I18n.t('select.dst_lpa.dst_lpa_options.not_done')]]
    end

    def media_options
      [
        ['solid', I18n.t('select.dst_lpa.method_options.solid')],
        ['liquid', I18n.t('select.dst_lpa.method_options.liquid')]
      ]
    end

    def method_options
      [
        ['direct', I18n.t('select.dst_lpa.method_options.direct')],
        ['indirect', I18n.t('select.dst_lpa.method_options.indirect')]
      ]
    end
  end
end
