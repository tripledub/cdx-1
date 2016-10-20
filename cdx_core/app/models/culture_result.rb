# Culture result model
class CultureResult < PatientResult
  include NotificationObserver

  validates_presence_of  :sample_collected_at, :examined_by, :result_at, :media_used, :test_result, on: :update
  validates_inclusion_of :test_result, in: %w(negative 1to9 1plus 2plus 3plus ntm contaminated), allow_nil: true
  validates_inclusion_of :media_used, in: %w(solid liquid), allow_nil: true
  validates_inclusion_of :result_status, in: %w(new sample_collected allocated pending_approval rejected completed), allow_nil: true

  delegate :patient, to: 'encounter'

  notification_observe_fields :result_status, :media_used, :test_result

  def localised_name
    I18n.t('culture_results.localised_name')
  end

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
