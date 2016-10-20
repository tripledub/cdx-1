# Dst/Lpa results model.
class DstLpaResult < PatientResult
  include NotificationObserver

  validates_presence_of :sample_collected_on, :examined_by, :result_on, :media_used,
                        :results_h, :results_r, :results_e, :results_s, :results_amk,
                        :results_km, :results_cm, :results_fq, on: :update
  validates_inclusion_of :results_h, :results_r, :results_e, :results_s,
                         :results_amk, :results_km, :results_cm, :results_fq,
                         in: %w(resistant susceptible contaminated not_done), allow_nil: true
  validates_inclusion_of :media_used, in: %w(solid liquid), allow_nil: true
  validates_inclusion_of :method_used, in: %w(direct indirect), allow_nil: true
  validates_inclusion_of :result_status, in: %w(new sample_collected allocated pending_approval rejected completed), allow_nil: true

  delegate :patient, to: 'encounter'

  notification_observe_fields :serial_number, :media_used,
                              :method_used, :results_h,
                              :results_r, :results_e,
                              :results_s, :results_amk,
                              :results_km, :results_cm,
                              :results_fq, :results_other1,
                              :result_status

  def localised_name
    return I18n.t('dst_lpa_results.dst_lpa') unless result_name

    if result_name.include? 'drugsusceptibility'
      I18n.t('dst_lpa_results.dst.localised_name')
    else
      I18n.t('dst_lpa_results.lpa.localised_name')
    end
  end

  class << self
    def dst_lpa_options
      [
        ['not_selected', I18n.t('select.dst_lpa.dst_lpa_options.not_selected_long'), I18n.t('select.dst_lpa.dst_lpa_options.not_selected')],
        ['resistant', I18n.t('select.dst_lpa.dst_lpa_options.resistant_long'), I18n.t('select.dst_lpa.dst_lpa_options.resistant')],
        ['susceptible', I18n.t('select.dst_lpa.dst_lpa_options.susceptible_long'), I18n.t('select.dst_lpa.dst_lpa_options.susceptible')],
        ['contaminated', I18n.t('select.dst_lpa.dst_lpa_options.contaminated_long'), I18n.t('select.dst_lpa.dst_lpa_options.contaminated')],
        ['not_done', I18n.t('select.dst_lpa.dst_lpa_options.not_done_long'), I18n.t('select.dst_lpa.dst_lpa_options.not_done')]
      ]
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
